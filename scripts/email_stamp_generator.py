#!/usr/bin/env python3
"""
Email Stamp Generator

Creates verifiable email stamps with QR codes and visual stamps.
Generates HTML email templates ready for sending.
"""

import hashlib
import base64
import qrcode
from io import BytesIO
from pathlib import Path
from typing import Optional
import argparse


class EmailStampGenerator:
    def __init__(self, stamp_image_path: Optional[str] = None):
        """
        Initialize the email stamp generator.
        
        Args:
            stamp_image_path: Path to the visual stamp image (PNG or JPEG)
        """
        self.stamp_image_path = stamp_image_path
        self.stamp_base64 = None
        
        if stamp_image_path:
            self._load_stamp_image()
    
    def _load_stamp_image(self):
        """Load and encode the stamp image as base64."""
        try:
            with open(self.stamp_image_path, 'rb') as f:
                image_data = f.read()
                image_ext = Path(self.stamp_image_path).suffix.lower()
                
                if image_ext in ['.png', '.jpg', '.jpeg']:
                    mime_type = 'image/png' if image_ext == '.png' else 'image/jpeg'
                    self.stamp_base64 = base64.b64encode(image_data).decode('utf-8')
                    self.stamp_mime_type = mime_type
                else:
                    raise ValueError(f"Unsupported image format: {image_ext}")
        except FileNotFoundError:
            raise FileNotFoundError(f"Stamp image not found: {self.stamp_image_path}")
        except Exception as e:
            raise Exception(f"Error loading stamp image: {str(e)}")
    
    def compute_hash(self, content: str) -> str:
        """
        Compute SHA256 hash of the email content.
        
        Args:
            content: Email content (subject + body)
            
        Returns:
            Hexadecimal hash string
        """
        hash_obj = hashlib.sha256(content.encode('utf-8'))
        return hash_obj.hexdigest()
    
    def generate_qr_code(self, hash_value: str) -> str:
        """
        Generate QR code image from hash and return as base64 string.
        
        Args:
            hash_value: SHA256 hash string
            
        Returns:
            Base64 encoded PNG image string
        """
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(hash_value)
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Convert to base64
        buffer = BytesIO()
        img.save(buffer, format='PNG')
        img_bytes = buffer.getvalue()
        img_base64 = base64.b64encode(img_bytes).decode('utf-8')
        
        return img_base64
    
    def generate_html_email(
        self,
        subject: str,
        body: str,
        include_pgp: bool = True,
        output_file: Optional[str] = None
    ) -> str:
        """
        Generate complete HTML email template with stamp and QR code.
        
        Args:
            subject: Email subject
            body: Email body text
            include_pgp: Whether to include PGP signature placeholder
            output_file: Optional output file path
            
        Returns:
            HTML email content as string
        """
        # Combine subject and body for hashing
        email_content = f"Subject: {subject}\n\n{body}"
        
        # Compute hash
        email_hash = self.compute_hash(email_content)
        
        # Generate QR code
        qr_code_base64 = self.generate_qr_code(email_hash)
        
        # Build HTML
        html = self._build_html_template(
            subject=subject,
            body=body,
            email_hash=email_hash,
            qr_code_base64=qr_code_base64,
            include_pgp=include_pgp
        )
        
        # Save to file if specified
        if output_file:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(html)
            print(f"HTML email saved to: {output_file}")
        
        return html
    
    def _build_html_template(
        self,
        subject: str,
        body: str,
        email_hash: str,
        qr_code_base64: str,
        include_pgp: bool
    ) -> str:
        """Build the HTML email template."""
        
        # Convert body text to HTML (preserve line breaks)
        body_html = body.replace('\n', '<br>\n')
        
        # Stamp image HTML
        stamp_html = ""
        if self.stamp_base64:
            stamp_html = f'''
            <div style="text-align: center; margin: 20px 0;">
                <img src="data:{self.stamp_mime_type};base64,{self.stamp_base64}" 
                     alt="Verification Stamp" 
                     style="max-width: 200px; height: auto; border: 2px solid #333; padding: 10px; background: white;">
            </div>
            '''
        
        # QR code HTML
        qr_html = f'''
        <div style="text-align: center; margin: 20px 0;">
            <h3 style="color: #333; margin-bottom: 10px;">Email Verification</h3>
            <img src="data:image/png;base64,{qr_code_base64}" 
                 alt="Email Hash QR Code" 
                 style="max-width: 200px; height: auto; border: 2px solid #333; padding: 10px; background: white;">
            <p style="font-size: 10px; color: #666; margin-top: 10px; font-family: monospace;">
                Hash: {email_hash}
            </p>
            <p style="font-size: 12px; color: #666; margin-top: 5px;">
                Scan this QR code to verify the email content integrity
            </p>
        </div>
        '''
        
        # PGP signature placeholder
        pgp_html = ""
        if include_pgp:
            pgp_html = '''
            <div style="margin: 30px 0; padding: 15px; background: #f5f5f5; border-left: 4px solid #007bff;">
                <h4 style="color: #333; margin-top: 0;">PGP Signature</h4>
                <div style="background: white; padding: 10px; border: 1px solid #ddd; font-family: monospace; font-size: 11px; color: #333; white-space: pre-wrap;">
-----BEGIN PGP SIGNATURE-----
[PGP signature will be inserted here]
-----END PGP SIGNATURE-----
                </div>
                <p style="font-size: 12px; color: #666; margin-top: 10px; margin-bottom: 0;">
                    PGP signature for additional cryptographic verification
                </p>
            </div>
            '''
        
        # Complete HTML template
        html_template = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{subject}</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f9f9f9;
        }}
        .email-container {{
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .subject {{
            font-size: 18px;
            font-weight: bold;
            color: #222;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #eee;
        }}
        .body {{
            font-size: 14px;
            color: #444;
            margin: 20px 0;
        }}
        .verification-section {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #eee;
        }}
        .hash-info {{
            background: #f8f9fa;
            padding: 10px;
            border-radius: 4px;
            margin-top: 10px;
        }}
    </style>
</head>
<body>
    <div class="email-container">
        <div class="subject">{subject}</div>
        
        <div class="body">
            {body_html}
        </div>
        
        {stamp_html}
        
        <div class="verification-section">
            {qr_html}
        </div>
        
        {pgp_html}
        
        <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; font-size: 11px; color: #999; text-align: center;">
            <p>This email includes cryptographic verification. The QR code contains a SHA256 hash of the email content.</p>
        </div>
    </div>
</body>
</html>'''
        
        return html_template


def main():
    """Command-line interface for the email stamp generator."""
    parser = argparse.ArgumentParser(
        description='Generate verifiable email stamps with QR codes',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  # Basic usage
  python email_stamp_generator.py -s "Hello" -b "This is the email body"
  
  # With visual stamp
  python email_stamp_generator.py -s "Hello" -b "Body" --stamp stamp.png
  
  # Without PGP placeholder
  python email_stamp_generator.py -s "Hello" -b "Body" --no-pgp
  
  # Custom output file
  python email_stamp_generator.py -s "Hello" -b "Body" -o email.html
        '''
    )
    
    parser.add_argument(
        '-s', '--subject',
        required=True,
        help='Email subject'
    )
    
    parser.add_argument(
        '-b', '--body',
        required=True,
        help='Email body text'
    )
    
    parser.add_argument(
        '--stamp',
        type=str,
        help='Path to visual stamp image (PNG or JPEG)'
    )
    
    parser.add_argument(
        '--no-pgp',
        action='store_true',
        help='Exclude PGP signature placeholder'
    )
    
    parser.add_argument(
        '-o', '--output',
        type=str,
        default='email_stamped.html',
        help='Output HTML file path (default: email_stamped.html)'
    )
    
    args = parser.parse_args()
    
    try:
        # Create generator
        generator = EmailStampGenerator(stamp_image_path=args.stamp)
        
        # Generate HTML email
        html = generator.generate_html_email(
            subject=args.subject,
            body=args.body,
            include_pgp=not args.no_pgp,
            output_file=args.output
        )
        
        # Compute and display hash
        email_content = f"Subject: {args.subject}\n\n{args.body}"
        email_hash = generator.compute_hash(email_content)
        
        print(f"\n✓ Email stamp generated successfully!")
        print(f"✓ SHA256 Hash: {email_hash}")
        print(f"✓ Output file: {args.output}\n")
        
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        return 1
    
    return 0


if __name__ == '__main__':
    import sys
    sys.exit(main())

