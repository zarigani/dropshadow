//
//  main.m
//  dropshadow
//
//  Created by zarigani on 2012/11/13.
//  Copyright (c) 2012年 bebe工房. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//影付きイメージを描画して返す
NSImage* dropshadowImage(NSImage *image)
{
    //スケールを取得する
    CGFloat scale = [[NSScreen mainScreen] backingScaleFactor];
    //Retina環境に応じたポイントサイズを取得する
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    NSSize pointSize = NSMakeSize([imageRep pixelsWide]/scale, [imageRep pixelsHigh]/scale);
    //描画する場所を準備
    NSRect newRect = NSZeroRect;
    newRect.size.width = pointSize.width + 20;
    newRect.size.height = pointSize.height + 20;
    NSImage *newImage = [[NSImage alloc] initWithSize:newRect.size];
    //描画する場所=newImageに狙いを定める、描画環境を保存しておく
    [newImage lockFocus];
    [NSGraphicsContext saveGraphicsState];
    //拡大・縮小した時の補間品質の指定
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    //影の設定
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:NSMakeSize(0.0, -2.0)];
    [shadow setShadowBlurRadius:8];
    [shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
    [shadow set];
    //描画する
    NSRect drawRect;
    drawRect.origin = NSMakePoint(10, 10);
    drawRect.size = pointSize;
    [image drawInRect:drawRect
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0
       respectFlipped:YES
                hints:nil];
    //描画環境を元に戻す、描画する場所=newImageから狙いを外す
    [NSGraphicsContext restoreGraphicsState];
    [newImage unlockFocus];
    //影付きのイメージを返す
    return newImage;
}

//PNGファイルとして保存する
void saveImageByPNG(NSImage *image, NSString* fileName)
{
    NSData *data = [image TIFFRepresentation];
    NSBitmapImageRep* bitmapImageRep = [NSBitmapImageRep imageRepWithData:data];
    NSDictionary* properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                           forKey:NSImageInterlaced];
    data = [bitmapImageRep representationUsingType:NSPNGFileType properties:properties];
    [data writeToFile:fileName atomically:YES];
}




int main(int argc, char *argv[])
{
//    return NSApplicationMain(argc, (const char **)argv);
        
    //ファイルパスをパースしておく
//    NSString *aPath = @"~/a/b/c.d.e";
    NSString *aPath = [NSString stringWithUTF8String:argv[1]];
    NSString *fPath = [aPath stringByStandardizingPath];        // /Users/HOME/a/b/c.d.e
    NSString *fDir = [fPath stringByDeletingLastPathComponent]; // /Users/HOME/a/b
    NSString *fNameExt = [fPath lastPathComponent];             // c.d.e
    NSString *fExt = [fPath pathExtension];                     // e
    NSString *fDirName = [fPath stringByDeletingPathExtension]; // /Users/HOME/a/b/c.d
//    NSLog(@"name.ext=%@  ext=%@  dir=%@  dir/name=%@", fNameExt, fExt, fDir, fDirName);
    NSString *shadowPath = [[fDirName stringByAppendingString:@"-shadow."] stringByAppendingString:fExt];
    
    //影付きイメージを生成する
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:fPath];
    NSImage *shadowImage = dropshadowImage(image);
    saveImageByPNG(shadowImage, shadowPath);
    
    //画像情報を出力する
    NSRect align = [shadowImage alignmentRect];
    NSLog(@"%@ (%f, %f, %f, %f)", shadowPath, align.origin.x, align.origin.y, align.size.width, align.size.height);
    return 0;
}
