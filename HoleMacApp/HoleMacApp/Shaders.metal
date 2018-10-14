//
//  Shaders.metal
//  HoleMacApp
//
//  Created by Chris Davis on 13/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void findEdges(device float *inArray [[buffer(0)]],
                      device float *outArray [[buffer(1)]],
                      device int *widthArray [[buffer(2)]],
                      device int *heightArray [[buffer(3)]],
                      uint2 gid [[thread_position_in_grid]]) {
    
    int width = int(widthArray[0]);
    int height = int(heightArray[0]);
    int totalLength = int(width * height);
    
    int startIndex = int((gid.y * width) + (gid.x * 9));
    
    //uint minX = (width * gid.y * 3) + (gid.x * 3);
    int finishIndex = startIndex + 9;
    
    for (int ptr = startIndex; ptr < finishIndex; ptr++) {
    
    //for (uint row = (gid.y * 3); row < (gid.y * 3) + 3; row++) {
    //    for (uint col = (gid.x * 3); col < (gid.x * 3) + 3; col++) {
    //int ptr = startIndex;
            float pixel = inArray[ptr];
            
            bool hasNegative = false;
            
            // Bottom left
            if ((ptr + width - 1) < totalLength) {
                if (inArray[ptr + width - 1] == -1) {
                    hasNegative = true;
                }
            }
//
//            // Bottom
            if ((ptr + width) < totalLength) {
                if (inArray[ptr + width] == -1) {
                    hasNegative = true;
                }
            }
//
//            // Bottom right
            if ((ptr + width + 1) < totalLength) {
                if (inArray[ptr + width + 1] == -1) {
                    hasNegative = true;
                }
            }
        
            // left
            if ((ptr - 1) > -1) {
                if (inArray[ptr - 1] == -1) {
                    hasNegative = true;
                }
            }
            
            // right
            if ((ptr + 1) < totalLength) {
                if (inArray[ptr + 1] == -1) {
                    hasNegative = true;
                }
            }
            
            // top left
            if ((ptr - width - 1) > -1) {
                if (inArray[ptr - width - 1] == -1) {
                    hasNegative = true;
                }
            }
//
//            // top
            if ((ptr - width ) > -1) {
                if (inArray[ptr - width ] == -1) {
                    hasNegative = true;
                }
            }
//
//            // top right
        if ((ptr - width + 1) > -1) {
            if (inArray[ptr - width + 1] == -1) {
                hasNegative = true;
            }
        }
        
            
            if (hasNegative && pixel != -1) {
                outArray[ptr] = 1;
            }
        
            if (gid.y == 0 && gid.x == 0 && ptr == 0) {
                //outArray[5] = inArray[ptr + width + 1];
            }
        
        }
    //}
}
