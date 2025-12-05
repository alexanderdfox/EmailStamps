# Metal Shader Library Error

## Error Message

```
precondition failure: unable to load binary archive for shader library: 
/System/Library/PrivateFrameworks/IconRendering.framework/Resources/binary.metallib, 
The file file:///System/Library/PrivateFrameworks/IconRendering.framework/Resources/binary.metallib 
has an invalid format.
```

## What This Means

This is a **system-level error** related to macOS's Metal shader library used for rendering SF Symbols (system images). It's not caused by the Email Stamp App code itself, but rather by:

1. **System file corruption** - The Metal shader library may be corrupted
2. **macOS version compatibility** - Some macOS versions have known issues with Metal shaders
3. **Hardware acceleration issues** - GPU or Metal driver problems

## Impact

This error typically:
- Appears in the console/logs
- Does **not** crash the app
- May cause SF Symbols to render incorrectly or not at all
- Is usually harmless but annoying

## Solutions

### 1. Restart Your Mac
Often fixes temporary system issues:
```bash
sudo reboot
```

### 2. Clear System Caches
Clear Metal shader caches:
```bash
# Clear Metal shader cache
rm -rf ~/Library/Caches/com.apple.metal
rm -rf ~/Library/Caches/com.apple.metal/*

# Clear system caches (requires admin)
sudo rm -rf /Library/Caches/com.apple.metal
```

### 3. Update macOS
Ensure you're running the latest macOS version:
```bash
softwareupdate -l
```

### 4. Reset NVRAM/PRAM
Reset system settings:
1. Shut down your Mac
2. Turn it on and immediately hold: `Option + Command + P + R`
3. Hold for about 20 seconds
4. Release and let it boot normally

### 5. Safe Mode
Boot into Safe Mode to check if third-party software is interfering:
1. Shut down your Mac
2. Turn it on and immediately hold: `Shift`
3. Release when you see the login window
4. Test the app in Safe Mode

### 6. Reinstall macOS
If the issue persists, consider reinstalling macOS (last resort):
- Use macOS Recovery Mode
- Reinstall macOS without erasing data

## Workarounds in the App

The app includes error handling to gracefully handle this issue:
- SF Symbols will fall back to basic rendering
- The app continues to function normally
- Error is logged but doesn't crash the app

## Reporting the Issue

If this error persists:
1. Check macOS version: `sw_vers`
2. Check Metal support: `system_profiler SPDisplaysDataType`
3. Report to Apple via Feedback Assistant
4. Include the full error message and system information

## Related Issues

- This error is known to occur on:
  - macOS 12.x (Monterey)
  - macOS 13.x (Ventura)
  - Some macOS 14.x (Sonoma) versions
- More common on:
  - Older Macs with integrated graphics
  - Macs with Metal driver issues
  - Systems with corrupted system files

## Prevention

To minimize this error:
- Keep macOS updated
- Don't modify system files
- Use official macOS updates only
- Avoid third-party system modifications

---

**Note:** This is a system-level issue, not an app bug. The app handles it gracefully, but the underlying system issue should be addressed for the best experience.

