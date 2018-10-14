//
//  Shaders.metal
//  HoleMacApp
//
//  Created by Chris Davis on 13/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//struct Point2D {
//    int x;
//    int xPad;
//    int xPad2;
//    int xPad3;
//    int y;
//};

struct PointWithValue2D {
    uint x;
    uint xPad;
    uint y;
    uint yPad;
    float value;
    float valuePad;
};

/**
 Take a 3by3 square and see if we make a 8by8 or 4by4 connected pixel.
 
 We are working with a 1-dimensional array at this point.
 */
kernel void findEdges(device float *inArray [[buffer(0)]],
                      device float *outArray [[buffer(1)]],
                      device int *widthArray [[buffer(2)]],
                      device int *heightArray [[buffer(3)]],
                      uint2 gid [[thread_position_in_grid]]) {
    
    int width = int(widthArray[0]);
    int height = int(heightArray[0]);
    int totalLength = int(width * height);
    
    int startIndex = int((gid.y * width) + (gid.x * 9));

    int finishIndex = startIndex + 9;
    
    for (int ptr = startIndex; ptr < finishIndex; ptr++) {

            float pixel = inArray[ptr];
            
            bool hasNegative = false;
            
            // Bottom left
            if ((ptr + width - 1) < totalLength) {
                if (inArray[ptr + width - 1] == -1) {
                    hasNegative = true;
                }
            }

            // Bottom
            if ((ptr + width) < totalLength) {
                if (inArray[ptr + width] == -1) {
                    hasNegative = true;
                }
            }

            // Bottom right
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

            // top
            if ((ptr - width ) > -1) {
                if (inArray[ptr - width ] == -1) {
                    hasNegative = true;
                }
            }

            // top right
            if ((ptr - width + 1) > -1) {
                if (inArray[ptr - width + 1] == -1) {
                    hasNegative = true;
                }
            }
        
            
            if (hasNegative && pixel != -1) {
                outArray[ptr] = 1;
            }
        
        }

}

float weighting(uint2 bounaryPixelLocation, uint2 missingPixelLocation, float z, float e) {
    
    float xDistance = missingPixelLocation.x - bounaryPixelLocation.x;
    float yDistance = missingPixelLocation.y - bounaryPixelLocation.y;
    
    float dist = sqrt(xDistance*xDistance + yDistance*yDistance);
    
    return 1 / (pow(dist, z) + e);
}



float newPixel(uint2 missingPixelLocation,
               device PointWithValue2D *boundaryPixels,
               uint boundaryCount,
               float z,
               float e) {
    
    float dividends = 0;
    float divisors = 0;
    for (uint i = 0; i < boundaryCount; i++) {
        uint2 boundaryPixelLocation = uint2(boundaryPixels[i].x, boundaryPixels[i].y);
        float weight = weighting(boundaryPixelLocation, missingPixelLocation, z, e);
        dividends += weight * boundaryPixels[i].value;
        divisors += weight;
    }
    float quotient = dividends / divisors;
    
    return quotient;
}


kernel void fillHole(device PointWithValue2D *boundaryPixels [[buffer(0)]],
                    // device uint2 *missingPixels [[buffer(1)]],
                     device float *inArray [[buffer(2)]],
                     device float *outArray [[buffer(3)]],
                     device int *widthArray [[buffer(4)]],
                     device int *heightArray [[buffer(5)]],
                     device int *missingPixelCountArray [[buffer(6)]],
                     device int *boundaryCountArray [[buffer(7)]],
                     device float *zArray [[buffer(8)]],
                     device float *eArray [[buffer(9)]],
                     uint2 gid [[thread_position_in_grid]]) {


    uint missingPixelCount = missingPixelCountArray[0];
    uint boundaryCount = boundaryCountArray[0];
    
    float z = zArray[0];
    float e = eArray[0];

    int width = int(widthArray[0]);
    int height = int(heightArray[0]);
    
    int startIndex = int((gid.y * width) + (gid.x * 9));
    
    int finishIndex = startIndex + 9;
    
    for (int ptr = startIndex; ptr < finishIndex; ptr++) {
        
        float pixel = inArray[ptr];

        if (pixel == -1) {

            uint x = ptr % width;
            uint y = ptr / width;
            uint2 missingPixelLocation = uint2(x,y);
            
            outArray[ptr] = newPixel(missingPixelLocation, boundaryPixels, boundaryCount, z, e);
        }
        
    }
    
//    if (gid.x == 0 && gid.y == 0) {
//        outArray[0] = inArray[startIndex + 4];
//    }

}
