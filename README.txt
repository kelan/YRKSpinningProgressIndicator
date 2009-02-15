YRKSpinningProgressIndicator and SPIDemo.app

Written by:
Kelan Champagne
http://yeahrightkeller.com
Please feel free to send me questions or comments.

History:
v1.0  2009-02-14  KJC


Overview:
YRKSpinningProgressIndicator is a clone of the NSProgressIndicator (spinning-style) that can be set to an arbitrary size and color.  The background color can also be set, or it can be transparent.  You can even change the color in real-time while it's animating.  SPIDemo is an app to demo its use.

Features:
* Can be set to arbitrary size and color.
    * Can even be changed while animating.
* Background color can be set, or transparent.
* Compatible with OS X 10.4 (Tiger).

Code Architecture:
* Implemented as a subclass of NSView.
* Animation is done with an NSTimer.


Code Conventions:
* Instance variables are prefixed with an underscore (i.e. "_").


License:

(The BSD License)

Copyright (c) 2009, Kelan Champagne (http://yeahrightkeller.com)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Kelan Champagne ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Kelan Champagne BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Also, I'd appreciate it if you would let me know if you find this code useful.

