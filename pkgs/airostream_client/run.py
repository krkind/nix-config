#!/usr/bin/env python
import subprocess
import time
import os

waiting_video_path = os.getenv('WAITING_VIDEO_PATH')

class StreamPlayer:
    def __init__(self, stream_url, fallback_video, check_interval_stream_up, check_interval_stream_down):
        self.stream_url = stream_url
        self.fallback_video = fallback_video
        self.check_interval_stream_up = check_interval_stream_up
        self.check_interval_stream_down = check_interval_stream_down
        self.stream_up = False
        self.vlc_process = None
        self.play_media(self.fallback_video, is_stream=False)

    def is_stream_available(self):
        print("Checking stream availability...")
        try:
            result = subprocess.run(
                ['ffprobe', '-v', 'error', '-rtsp_transport', 'tcp', '-i', self.stream_url],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5
            )
            return result.returncode == 0
        except Exception as e:
            print(f"Error checking stream: {e}")
            return False

    def kill_vlc(self):
        print("Killing VLC...")
        if self.vlc_process:
            try:
                self.vlc_process.terminate()
                self.vlc_process.wait()
                self.vlc_process = None
            except Exception as e:
                print(f"Error killing VLC: {e}")

    def play_media(self, source, is_stream):
        self.kill_vlc()
        try:
            print("Stating VLC ")
            self.vlc_process = subprocess.Popen([
                'cvlc', '--repeat', '--no-osd', '--fullscreen',
                '--network-caching=0', '--no-skip-frames', '--sout-mux-caching=10',
                '--file-caching=0', '--live-caching=0', '--rtsp-frame-buffer-size=10000',
                '--drop-late-frames', '--skip-frames', source
            ])
        except Exception as e:
            print(f"Error launching VLC: {e}")

    def run(self):
        while True:
            if self.is_stream_available():
                if not self.stream_up:
                    print("Stream is available. Playing RTSP stream.")
                    self.play_media(self.stream_url, is_stream=True)
                    self.stream_up = True
            else:
                if self.stream_up:
                    print("Stream is down. Playing fallback video.")
                    self.play_media(self.fallback_video, is_stream=False)
                    self.stream_up = False

            if self.stream_up:
                time.sleep(self.check_interval_stream_up)
            else:
                print('Stream is down')
                time.sleep(self.check_interval_stream_down)

if __name__ == "__main__":
    stream_url = "rtsp://192.168.43.2:8554/airostream"
    fallback_video = waiting_video_path
    check_interval_stream_up = 10
    check_interval_stream_down = 0.5

    player = StreamPlayer(stream_url, fallback_video, check_interval_stream_up, check_interval_stream_down)
    player.run()
