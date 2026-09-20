## tunnel

```bash
ssh -CN -L5038:localhost:5037 -R27183:localhost:27183 reid@nixos-sbc0
```

## command

```bash
scrcpy -b 512K --video-buffer=500 --max-fps=15  --print-fps
```

with audio

```bash
export ADB_SERVER_SOCKET=tcp:localhost:5038
scrcpy --audio-source=mic --audio-bit-rate=48k --audio-buffer=500  --video-bit-rate=512K  --video-buffer=500 --max-fps=15  --print-fps
```

## voice

```bash
rec -c 1 -t flac - | ssh reid@nixos-sbc0 sox  -t flac - -t alsa 'sysdefault:CARD=Device'
```

```bash
ssh reid@nixos-sbc0 sox -t alsa 'sysdefault:CARD=Codec' -t flac - | play -t flac -
```
