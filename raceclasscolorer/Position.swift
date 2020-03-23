//
//  Position.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 3/9/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import Foundation

typealias Position = (x: Int, y: Int)

//http://eugen.dedu.free.fr/projects/bresenham/
func smartVisionLine(position1: Position, position2: Position) -> [Position] {
    var ystep: Int
    var xstep: Int
    var error: Int
    var errorprev: Int
    var y = position1.y
    var x = position1.x
    var ddy: Int
    var ddx: Int
    var dx = position2.x - position1.x
    var dy = position2.y - position1.y
    
    var pointsOnLine = [Position]()
    
    pointsOnLine.append(position1)
    
    if dy < 0 {
        ystep = -1
        dy = -dy
    } else {
        ystep = 1
    }
    
    if dx < 0 {
        xstep = -1
        dx = -dx
    } else {
        xstep = 1
    }
    
    ddy = 2 * dy
    ddx = 2 * dx
    
    if ddx >= ddy {
        errorprev = dx
        error = dx
        
        for _ in 0..<dx {
            x += xstep
            error += ddy
            if error > ddx {
                y += ystep
                error -= ddx
                
                if error + errorprev < ddx {
                    pointsOnLine.append(Position(x: x, y: y-ystep))
                } else if error + errorprev > ddx {
                    pointsOnLine.append(Position(x: x-xstep, y: y))
                } else {
//                    pointsOnLine.append(Position(x: x, y: y-ystep))
//                    pointsOnLine.append(Position(x: x-xstep, y: y))
                }
            }
            pointsOnLine.append(Position(x: x, y: y))
            errorprev = error
        }
    } else {
        errorprev = dy
        error = dy
        
        for _ in 0..<dy {
            y += ystep
            error += ddx
            if error > ddy {
                x += xstep
                error -= ddy
                
                if error + errorprev < ddy {
                    pointsOnLine.append(Position(x: x-xstep, y: y))
                } else if error + errorprev > ddy {
                    pointsOnLine.append(Position(x: x, y: y-ystep))
                } else {
                    pointsOnLine.append(Position(x: x, y: y-ystep))
                    pointsOnLine.append(Position(x: x-xstep, y: y))
                }
            }
            pointsOnLine.append(Position(x: x, y: y))
            errorprev = error
        }
    }
    
    return pointsOnLine
}

func distanceHisc(position1: Position, position2: Position) -> Double {
    return pow(Double(position1.x - position2.x), 2) + pow(Double(position1.y - position2.y), 2)
}
