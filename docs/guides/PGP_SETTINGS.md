# PGP Settings Guide

## Overview

The Email Stamp app now includes comprehensive PGP (Pretty Good Privacy) settings for configuring email signing and encryption.

## Accessing PGP Settings

1. **From the Compose Window**:
   - Click the **"PGP Settings"** button in the toolbar
   - Or use the **"Include PGP"** toggle and click **"PGP Settings"** for advanced options

2. **Settings Panel**:
   - Opens a dedicated settings window
   - All settings are saved automatically when you click **"Save"**

## PGP Settings Options

### Enable PGP Signing
- **Toggle**: Enable/disable PGP signing globally
- When enabled, PGP signature placeholders will be included in emails
- When disabled, no PGP section appears in generated emails

### Signature Style
Choose how PGP signatures are formatted:

- **Inline**: Signature is embedded within the email body
- **Detached**: Signature is provided as a separate attachment
- **Clear Text**: Signature is in clear text format (readable)

### Auto-sign All Emails
- When enabled, all emails are automatically signed (if PGP is enabled)
- When disabled, you can toggle signing per email

### Key File Path
- **Browse**: Select your PGP private key file
- Supported formats: `.asc`, `.gpg`, `.key`
- The app will verify if the file exists
- Shows a checkmark (✓) if configured, warning (⚠) if file not found

### Key ID (Optional)
- Enter your PGP key ID in one of these formats:
  - Hexadecimal: `0x12345678`
  - Email: `user@example.com`
  - Short ID: `12345678`
- Leave empty to use your default key from GPG keyring

### Key Password (Optional)
- Enter the password for your PGP key if required
- **Security Note**: Password is NOT saved for security reasons
- You'll need to enter it each time if your key requires a password

## Settings Persistence

- All settings (except password) are saved to UserDefaults
- Settings persist between app launches
- Password is never saved for security

## PGP Signature in Generated Emails

When PGP is enabled, the generated HTML email includes:

1. **PGP Signature Section**:
   - Shows the signature style (Inline/Detached/Clear Text)
   - Displays key information (Key ID or file path)
   - Placeholder for actual PGP signature

2. **Key Information**:
   - Shows which key will be used for signing
   - Helps verify the correct key is configured

## Integration with Email Generation

The PGP settings are integrated into the email generation process:

- Settings are passed to the HTML generator
- Signature style affects how the placeholder is displayed
- Key information is included in the signature block
- Settings are respected when generating previews

## Requirements

### For Actual PGP Signing

To actually sign emails (not just placeholders), you need:

1. **GPG Installed**:
   ```bash
   # Check if GPG is installed
   gpg --version
   
   # Install on macOS
   brew install gnupg
   ```

2. **PGP Key Setup**:
   ```bash
   # List your keys
   gpg --list-secret-keys
   
   # Import a key
   gpg --import your-key.asc
   ```

3. **Key Configuration**:
   - Either provide the key file path in settings
   - Or configure your default key in GPG

### Current Implementation

**Note**: The current version generates PGP signature **placeholders** in the HTML. To add actual PGP signing functionality, you would need to:

1. Integrate with GPG command-line tools
2. Call `gpg --sign` or `gpg --clearsign` commands
3. Embed the actual signature in the email

## Example Configuration

### Basic Setup:
1. Enable PGP Signing: **ON**
2. Signature Style: **Inline**
3. Key File Path: `/Users/you/.gnupg/private-key.asc`
4. Auto-sign: **OFF** (sign manually per email)

### Advanced Setup:
1. Enable PGP Signing: **ON**
2. Signature Style: **Detached**
3. Key ID: `0xABCD1234`
4. Key Password: (entered when needed)
5. Auto-sign: **ON**

## Troubleshooting

### "Key file not found"
- Verify the file path is correct
- Check file permissions
- Ensure the file exists at the specified location

### "No key configured"
- Either provide a key file path OR a key ID
- Check that your GPG keyring has keys if using Key ID

### Settings Not Saving
- Ensure you click **"Save"** in the settings window
- Check that UserDefaults is accessible
- Restart the app if settings don't persist

## Security Notes

1. **Password Storage**: Passwords are never saved
2. **Key Files**: Store private keys securely
3. **Key Permissions**: Ensure key files have appropriate permissions (600)
4. **Keychain**: Consider using macOS Keychain for key storage

## Future Enhancements

Potential features for future versions:

- Direct GPG integration for actual signing
- Keychain integration for secure key storage
- Multiple key support
- Encryption support (not just signing)
- Key generation wizard
- Key validation and testing

