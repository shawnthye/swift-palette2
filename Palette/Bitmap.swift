//
//  Bitmap.swift
//  Palette
//
//  Created by Shawn Thye on 21/11/2018.
//  Copyright © 2018 Jonathan Zong. All rights reserved.
//

import Foundation

extension Bitmap {
    
    private func createARGBBitmapContext() -> CGContext? {
        
        //Get image width, height
        let pixelsWide = self.width
        let pixelsHigh = self.height
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapBytesPerRow * pixelsHigh)
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGContext(data: bitmapData, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        return context
    }
    
    public func getPixels(pixels: inout [ColorInt], offset: Int, stride: Int, x: Int, y: Int, width: Int, height: Int) {
        guard let context = self.createARGBBitmapContext() else {
            return
        }
        
        let pixelsWide = self.width
        let pixelsHigh = self.height
        let rect = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)
        //Clear the context
        context.clear(rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        context.draw(self, in: rect)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return
        }
        
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        for i in 0..<width * height {
            let offset = i * 4
            let alpha = dataType[offset]
            let red = dataType[offset + 1]
            let green = dataType[offset + 2]
            let blue = dataType[offset + 3]
            pixels[i] = Color.argb(alpha: Int(alpha),
                                   red: Int(red),
                                   green: Int(green),
                                   blue: Int(blue))
        }
        
        pixels = [Int](pixels[x * y..<width * height])
        
        //        for x in 0..<pixelsWide {
        //            for y in 0..<pixelsHigh {
        //                let offset = 4 * ((Int(pixelsWide) * Int(y)) + Int(x))
        //                let alpha = dataType[offset]
        //                let red = dataType[offset + 1]
        //                let green = dataType[offset + 2]
        //                let blue = dataType[offset + 3]
        //                let argb = Color.argb(alpha: Int(alpha),
        //                                            red: Int(red),
        //                                            green: Int(green),
        //                                            blue: Int(blue))
        //                if alpha == 0 {
        //                    print("nonono \(ColorInt.toHexString(argb))")
        //                }
        //                pixels.append(argb)
        //            }
        //        }
        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
//
//        let finalcontext = CGContext(data: data, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8,  bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
//
//        let imageRef = finalcontext!.makeImage()
    }
    
    func resize(scale: Double) -> Bitmap {
        let image = UIImage(cgImage: self)
        let size = image.size.applying(CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale)))
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        
        let context = UIGraphicsGetImageFromCurrentImageContext()
        let scaledBitmap = context?.cgImage
        UIGraphicsEndImageContext()
        
        guard let bitmap = scaledBitmap else {
            return self
        }
        
        return bitmap
    }
}
