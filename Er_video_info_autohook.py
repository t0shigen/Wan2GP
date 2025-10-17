# Er_video_info_autohook.py
# ------------------------------------------------------------
# Autohook สำหรับโชว์ข้อมูลวิดีโอ (Frames / FPS / Resolution)
# - ปลอดภัยต่อการถูกโหลดซ้ำ (process-level + gradio-level guards)
# - ผูก callback ให้อัตโนมัติทุก gr.Video / gr.File / gr.Files ในทุกๆ gr.Blocks
# - รองรับ Toast (Windows 10/11) ถ้าติดตั้ง win10toast และตั้ง WGP_SHOW_TOAST=1
# - ffprobe: ชี้ด้วย WGP_FFPROBE; ถ้าไม่ตั้งจะพยายามใช้ .\ffprobe.exe หรือ "ffprobe" ใน PATH
# ------------------------------------------------------------

import os, sys, json, subprocess

# ------------ Process-level guard (กันรันไฟล์นี้ซ้ำในโปรเซสเดียว) ------------
if getattr(sys, "_ER_VI_HOOK_DONE", False):
    print("[VideoInfo] already loaded (process guard), skip.", flush=True)
else:
    setattr(sys, "_ER_VI_HOOK_DONE", True)

    print("[autohook] Er_video_info_autohook loaded ✅", flush=True)

    # ------------ ffprobe path ------------
    _here = os.path.dirname(os.path.abspath(__file__))
    _local_ffprobe = os.path.join(_here, "ffprobe.exe")
    FFPROBE_PATH = os.getenv("WGP_FFPROBE", _local_ffprobe if os.path.exists(_local_ffprobe) else "ffprobe")

    # ------------ core: read video info using ffprobe ------------
    def get_video_info(path: str):
        """
        คืนค่าข้อมูล video (duration, width, height, fps, frames) หรือ None ถ้าล้มเหลว
        """
        if not isinstance(path, str) or not os.path.isfile(path):
            print(f"[autohook] file not found: {path}", flush=True)
            return None

        cmd = [
            FFPROBE_PATH,
            "-v", "error",
            "-select_streams", "v:0",
            "-count_frames",
            "-show_entries", "stream=width,height,r_frame_rate,nb_read_frames",
            "-show_entries", "format=duration",
            "-of", "json",
            path
        ]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            data = json.loads(result.stdout or "{}")
            info = {}
            s = (data.get("streams") or [None])[0] or {}
            info["width"]  = int(s.get("width")  or 0)
            info["height"] = int(s.get("height") or 0)
            # r_frame_rate -> fps
            r = s.get("r_frame_rate") or "0/0"
            try:
                num, den = map(int, r.split("/"))
                info["fps"] = float(num / den) if den else 0.0
            except Exception:
                info["fps"] = 0.0
            # frames (nb_read_frames) อาจเป็นสตริง
            nb = s.get("nb_read_frames")
            try:
                info["frames"] = int(nb) if nb is not None else None
            except Exception:
                info["frames"] = None
            # duration
            try:
                info["duration"] = float((data.get("format") or {}).get("duration") or 0.0)
            except Exception:
                info["duration"] = 0.0
            # คำนวณ frames ถ้า ffprobe ไม่ให้มา
            if info.get("frames") is None and info.get("duration") and info.get("fps"):
                info["frames"] = int(round(info["duration"] * info["fps"]))
            return info
        except Exception as e:
            print(f"[autohook] ffprobe error: {e}", flush=True)
            return None

    # ------------ formatter & toast ------------
    def _format_info(label: str, info: dict | None) -> str:
        if not info:
            return f"[{label}] cannot read info"
        w = info.get("width") or 0
        h = info.get("height") or 0
        fps = float(info.get("fps") or 0.0)
        frames = info.get("frames")
        if frames is None and info.get("duration") and fps:
            frames = int(round(info["duration"] * fps))
        return f"[{label}] Frames: {frames if frames is not None else '?'} | Framerate: {fps:.3f} fps | Resolution: {w} × {h}"

    # --- Toast with winotify (Win10/11 native), fallback to win10toast ---
    _TOASTER = None  # สำหรับ fallback win10toast เท่านั้น
    
    def _toast(msg: str):
        if os.getenv("WGP_SHOW_TOAST", "0") != "1":
            return
        # ระยะเวลา: ค่าจาก env หน่วยวินาที (0/ว่าง = short)
        try:
            dur_sec = int(os.getenv("WGP_TOAST_DURATION", "0") or "0")
        except Exception:
            dur_sec = 0
    
        # 1) ลอง winotify ก่อน (แนะนำสุดสำหรับ Win11)
        try:
            from winotify import Notification
            duration = "long" if dur_sec >= 5 else "short"   # winotify ใช้ 'short'/'long'
            Notification(
                app_id="Wan2GP",
                title="Video Info",
                msg=msg,
                duration=duration
            ).show()
            return
        except Exception as e:
            print("[VideoInfo][toast] winotify failed -> fallback to win10toast:", e, flush=True)
    
        # 2) Fallback: win10toast (แก้ไม่ให้ส่ง None และไม่สร้าง instance ซ้ำ)
        try:
            from win10toast import ToastNotifier
            global _TOASTER
            if _TOASTER is None:
                _TOASTER = ToastNotifier()
            if dur_sec <= 0:
                dur_sec = 5  # ต้องเป็น int >0 เสมอ
            _TOASTER.show_toast("Video Info", msg, duration=dur_sec, threaded=True)
        except Exception as e:
            print("[VideoInfo][toast] fallback win10toast failed:", e, flush=True)



    # ------------ Gradio auto-bind (Blocks/Component hooks) ------------
    try:
        import gradio as gr

        # gradio-level guard: กันแพตช์ซ้ำแค่ในระดับกรอบ Gradio
        if getattr(gr.Blocks, "_vi_patched", False):
            print("[VideoInfo] already installed (gradio guard), skip re-patch.", flush=True)
        else:
            setattr(gr.Blocks, "_vi_patched", True)

            # resolve Component base class (รองรับหลายเวอร์ชัน)
            try:
                from gradio.components.base import Component as _CompBase
            except Exception:
                from gradio.components import Component as _CompBase  # fallback

            # เก็บ originals (ครั้งแรกเท่านั้น)
            if not hasattr(_CompBase, "_vi_orig_init"):
                _CompBase._vi_orig_init = _CompBase.__init__
            if not hasattr(gr.Blocks, "_vi_orig_enter"):
                gr.Blocks._vi_orig_enter = gr.Blocks.__enter__
            if not hasattr(gr.Blocks, "_vi_orig_exit"):
                gr.Blocks._vi_orig_exit  = gr.Blocks.__exit__

            _STACK = []  # เก็บคอมโพเนนต์ที่ถูกสร้างในแต่ละ Blocks

            def _patched_comp_init(self, *a, **k):
                _CompBase._vi_orig_init(self, *a, **k)
                if _STACK:
                    _STACK[-1].append(self)
            _CompBase.__init__ = _patched_comp_init

            def _resolve_path(v):
                if v is None:
                    return None
                if isinstance(v, str) and os.path.exists(v):
                    return v
                if isinstance(v, dict):
                    for key in ("name", "path", "tempfile"):
                        p = v.get(key)
                        if isinstance(p, str) and os.path.exists(p):
                            return p
                if isinstance(v, (list, tuple)) and v:
                    return _resolve_path(v[0])
                return None

            def _make_cb(label: str):
                def _cb(value):
                    p = _resolve_path(value)
                    if not p:
                        print(f"[VideoInfo][{label}] no file", flush=True)
                        return
                    info = get_video_info(p)
                    line = _format_info(label, info)
                    print(line, flush=True)
                    _toast(line)
                return _cb

            def _patched_enter(self, *a, **k):
                obj = gr.Blocks._vi_orig_enter(self, *a, **k)
                _STACK.append([])
                return obj

            def _bind_for_list(items):
                for comp in items:
                    label = getattr(comp, "label", None) or comp.__class__.__name__
                    try:
                        if isinstance(comp, (gr.Video, gr.File, gr.Files)):
                            cb = _make_cb(label)
                            bound = False
                            if hasattr(comp, "upload"):
                                try:
                                    comp.upload(fn=cb, inputs=comp, outputs=None)
                                    bound = True
                                except Exception as e:
                                    print(f"[VideoInfo][bind][{label}] upload fail: {e}", flush=True)
                            if (not bound) and hasattr(comp, "change"):
                                try:
                                    comp.change(fn=cb, inputs=comp, outputs=None)
                                    bound = True
                                except Exception as e:
                                    print(f"[VideoInfo][bind][{label}] change fail: {e}", flush=True)
                            print(f"[VideoInfo][bind][{label}] bound={bound}", flush=True)
                    except Exception as e:
                        print(f"[VideoInfo][bind][err] {e}", flush=True)

            def _patched_exit(self, exc_type, exc, tb):
                items = _STACK.pop() if _STACK else []
                try:
                    _bind_for_list(items)
                except Exception as e:
                    print(f"[VideoInfo] bind list error: {e}", flush=True)
                return gr.Blocks._vi_orig_exit(self, exc_type, exc, tb)

            gr.Blocks.__enter__ = _patched_enter
            gr.Blocks.__exit__  = _patched_exit

            print("[VideoInfo] autohook installed (Blocks enter/exit).", flush=True)

    except Exception as e:
        print(f"[VideoInfo] autohook skipped: {e}", flush=True)
