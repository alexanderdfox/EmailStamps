# Email Stamp - Custom Email App

A standalone macOS email application with built-in cryptographic verification, QR codes, and visual stamps.

## Features

- **Full Email Composition**: Write emails with a modern SwiftUI interface
- **Cryptographic Verification**: SHA256 hashing of email content
- **QR Code Generation**: Automatic QR codes for email verification
- **Visual Stamps**: Add custom PNG/JPEG stamp images to emails
- **PGP Signature Support**: Optional PGP signature placeholders
- **HTML Email Generation**: Creates ready-to-send HTML emails
- **Email History**: View previously composed emails
- **Live Preview**: See your email as it will appear
- **Export Options**: Copy to clipboard or save as HTML file

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for building)

## Building the App

### Using Xcode

1. Open the project:
   ```bash
   open EmailStampApp.xcodeproj
   ```

2. Select the **EmailStampApp** scheme

3. Build and run (⌘R)

### Using Command Line

```bash
cd EmailStampApp
xcodebuild -project EmailStampApp.xcodeproj -target EmailStampApp -configuration Release
```

The app will be built to:
```
build/Release/EmailStampApp.app
```

## Usage

### Composing an Email

1. **Launch the app**
2. Click **"New Email"** button (or press ⌘N)
3. Fill in:
   - **To**: Recipient email address
   - **Subject**: Email subject
   - **Body**: Email content
4. **Optional**: Click **"Add Stamp"** to add a visual stamp image
5. **Optional**: Toggle **"Include PGP"** for PGP signature placeholder
6. Click **"Send"** when ready

### Adding a Visual Stamp

1. Click **"Add Stamp"** button
2. Select a PNG or JPEG image
3. The stamp will be embedded in the email
4. Click **"Remove"** to remove the stamp

### Sending Options

When you click **"Send"**, you'll get options:

- **Copy HTML**: Copies the HTML email to clipboard (paste into any email client)
- **Save File**: Saves the HTML email as a file
- **Cancel**: Returns to editing

### Viewing Email History

- Previously composed emails appear in the left sidebar
- Click an email to view it
- Click **"New Email"** to compose a new one

## Features in Detail

### Cryptographic Verification

- **SHA256 Hash**: Computed from email subject + body
- **QR Code**: Contains the hash for easy verification
- **Hash Display**: Shown in the compose window

### HTML Email Output

The generated HTML includes:
- Styled email body
- Visual stamp (if added)
- QR code with hash
- PGP signature placeholder (if enabled)
- Professional email styling

### Export Options

1. **Copy to Clipboard**: 
   - HTML format for rich email clients
   - Plain text fallback
   - Paste directly into Gmail, Outlook, etc.

2. **Save as File**:
   - Saves as `.html` file
   - Can be opened in any browser
   - Can be imported into email clients

## Architecture

- **SwiftUI**: Modern declarative UI
- **MVVM Pattern**: ViewModel manages state
- **CryptoKit**: SHA256 hashing
- **CoreImage**: QR code generation
- **WebKit**: HTML preview

## File Structure

```
Sources/EmailStampApp/
├── EmailStampApp.swift          # Main app + all views
├── EmailStampGenerator.swift   # Stamp generation logic
└── (other supporting files)
```

## Customization

### Change Default Settings

Edit `EmailComposeViewModel`:
- Default PGP inclusion
- Email storage location
- Hash algorithm (currently SHA256)

### Modify HTML Template

Edit `EmailStampGenerator.buildHTMLTemplate()`:
- Change styling
- Modify layout
- Add custom sections

### Add Email Sending

To add actual SMTP sending:
1. Add a network library (e.g., SwiftSMTP)
2. Implement `sendEmail()` in ViewModel
3. Add SMTP configuration UI

## License

Free to use and modify.

