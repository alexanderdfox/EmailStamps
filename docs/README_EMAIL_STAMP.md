# Email Stamp Generator

A Python script that creates verifiable email stamps with QR codes and visual stamps for cryptographic verification.

## Features

- **SHA256 Hashing**: Computes cryptographic hash of email content (subject + body)
- **QR Code Generation**: Creates QR code from the hash for easy verification
- **Visual Stamp Embedding**: Embeds custom stamp images (PNG/JPEG) inline
- **PGP Signature Placeholder**: Optional section for PGP signatures
- **HTML Email Template**: Generates ready-to-send HTML emails
- **Base64 Encoding**: All images embedded inline (no external dependencies)

## Requirements

```bash
pip install qrcode[pil]
```

## Usage

### Command Line

```bash
# Basic usage
python email_stamp_generator.py -s "Email Subject" -b "Email body text here"

# With visual stamp image
python email_stamp_generator.py -s "Hello" -b "This is the email body" --stamp stamp.png

# Without PGP placeholder
python email_stamp_generator.py -s "Hello" -b "Body" --no-pgp

# Custom output file
python email_stamp_generator.py -s "Hello" -b "Body" -o my_email.html
```

### Python API

```python
from email_stamp_generator import EmailStampGenerator

# Create generator with stamp image
generator = EmailStampGenerator(stamp_image_path="stamp.png")

# Generate HTML email
html = generator.generate_html_email(
    subject="Test Email",
    body="This is the email body content.",
    include_pgp=True,
    output_file="output.html"
)

# Or use individual methods
email_content = "Subject: Test\n\nBody text"
hash_value = generator.compute_hash(email_content)
qr_code = generator.generate_qr_code(hash_value)
```

## How It Works

1. **Content Hashing**: The script combines the subject and body, then computes a SHA256 hash
2. **QR Code Generation**: Creates a QR code containing the hash value
3. **Image Embedding**: Converts stamp images and QR codes to base64 for inline embedding
4. **HTML Generation**: Builds a complete HTML email template with all elements

## Output

The generated HTML file includes:
- Email subject and body
- Visual stamp image (if provided)
- QR code for verification
- SHA256 hash display
- Optional PGP signature section
- Professional styling for email clients

## Verification

To verify an email:
1. Scan the QR code with any QR code reader
2. Compare the hash with a recomputed hash of the email content
3. Optionally verify the PGP signature if present

## Example Output

The generated HTML will display:
- Clean, professional email layout
- Centered stamp image
- QR code with hash information
- PGP signature block (if enabled)
- Verification instructions

## License

Free to use and modify.

