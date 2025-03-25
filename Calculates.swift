//
//  Calculates.swift
//  YueNong
//
//  Created by 冯贺 on 2020/9/21.
//  Copyright © 2020 冯贺. All rights reserved.
//

import UIKit
import Turf
import CoreLocation
import GEOSwift


 
let ne:CLLocationCoordinate2D
let sw:CLLocationCoordinate2D

@objcMembers public class Calculates: NSObject {
    
    public func buffereds(coordinates:Array<CLLocation>, lineWight: Double) ->NSDictionary { //计算buffer lineWight 为经纬度距离 0.00001度 约等于1米
        
        var polyonStr = ""
        for coords in coordinates {
            polyonStr =  polyonStr + String(format: "%lf", coords.coordinate.latitude) + " " + String(format: "%lf", coords.coordinate.longitude) + ","
        }

        polyonStr.remove(at: polyonStr.index(before: polyonStr.endIndex))
        polyonStr = "LINESTRING (" + polyonStr + ")"
        let polygon = try! LineString(wkt:polyonStr)
        let multipolyons   = try! polygon.buffer(by: lineWight)
     
        let  array:NSMutableArray = [];
        
        switch multipolyons {
       
        case let .polygon(polygon):
            
            for point in polygon.exterior.points {
                
                let loction = CLLocation(latitude: point.x, longitude: point.y)
                array.addObjects(from: [loction])
            }
            
            let holes:NSMutableArray = []
            for points in  polygon.holes {
                let holesArray:NSMutableArray = []
                for point in points.points {
                    
                    let loction = CLLocation(latitude: point.x, longitude: point.y)
                    holesArray.addObjects(from: [loction])
                }
                holes.addObjects(from: [holesArray])
                
            }
            
            
            return ["points":array,
                     "holes":holes] ;
        default:
            return [:]
            
        }
        
        
    }
    

    public func Calculates(coordinates:Array<CLLocation>) -> Double {//计算面积
        
        var array = [CLLocationCoordinate2D]()
        for coord in coordinates {
            
            array.append(coord.coordinate)
        }
        
        let areaNum  = Turf.Polygon([array])
        
        return areaNum.area
        
        
    }
    
    public func CalculatesPolygonGravityCenter(coordinates: Array<CLLocation>) -> CLLocationCoordinate2D {//计算面的中心点
        var array = [CLLocationCoordinate2D]()
        for coord in coordinates {
            
            
            array.append(coord.coordinate)
        }
//        var area = 0.0 // 多边形面积
//        var gravityLat = 0.0 // 重心点 latitude
//        var gravityLng = 0.0 // 重心点 longitude
//        for (index, coordinate) in array.enumerated() {
//              // 1
//            let lat = coordinate.latitude
//            let lng = coordinate.longitude
//            let nextLat = array[(index + 1) % coordinates.count].latitude
//            let nextLng = array[(index + 1) % coordinates.count].longitude
//              // 2
//            let tempArea = (nextLat * lng - nextLng * lat) / 2.0
//              // 3
//            area += tempArea
//              // 4
//            gravityLat += tempArea * (lat + nextLat) / 3
//            gravityLng += tempArea * (lng + nextLng) / 3
//        }
//          // 5
//        gravityLat = gravityLat / area
//        gravityLng = gravityLng / area
        let box = Turf.BoundingBox(from: array)
        var CLLocationArray = [CLLocation]()
        
        CLLocationArray.append(CLLocation(latitude: box!.northEast.latitude, longitude: box!.northEast.longitude))
        CLLocationArray.append(CLLocation(latitude: box!.southWest.latitude, longitude: box!.southWest.longitude))
//        let mid = Turf.mid(box!.northEast, box!.southWest)
        return self.calculatPointMid(coordinates: CLLocationArray)
    }
    
    public func calculatContains(coordinates:Array<CLLocation>,coord:CLLocationCoordinate2D) -> Bool {//计算点是否在面里边
        
        var array = [CLLocationCoordinate2D]()
        for coord in coordinates {
           
            array.append(coord.coordinate)
        }
        
        let areaNum  = Turf.Polygon([array])

        return areaNum.contains(coord, ignoreBoundary: true)
        
        
    }
    
    public func calculatNorthEastPoint(coordinates:Array<CLLocation>) -> CLLocationCoordinate2D {//计算面的东北点
        
        var array = [CLLocationCoordinate2D]()
        for coord in coordinates {
            
            array.append(coord.coordinate)
        }
        let box = Turf.BoundingBox(from: array)
        ne = box!.northEast
        return box!.northEast
   
    }
    
    public func calculatSouthWestPoint(coordinates:Array<CLLocation>) -> CLLocationCoordinate2D {//计算面的西南点
        
        var array = [CLLocationCoordinate2D]()
        for coord in coordinates {
            
            array.append(coord.coordinate)
        }
        let box = Turf.BoundingBox(from: array)
        sw = box!.southWest
        return box!.southWest
   
    }
    
    public func calculatWidth(coordinates:Array<CLLocation>) -> Double {//计算折线的距离
        
        var array = [CLLocationCoordinate2D]()
        
        for coord in coordinates {

            array.append(coord.coordinate)
        }
        let Line = Turf.LineString(array)
        
        return Line.distance(from: sw, to: ne)!
   
    }
    
    
    
    public func calculatPointMid(coordinates:Array<CLLocation>) -> CLLocationCoordinate2D {//计算两点中心点
    
        let firstPoint = coordinates.first
        let lastPoint = coordinates.last

        
        return Turf.mid(firstPoint!.coordinate, lastPoint!.coordinate)
   
    }
    
    
    
    
    public func calculatPointToPolygon(coordinates:Array<CLLocation>,mainLocation:CLLocation) -> Double    {//点到面的距离  也可以计算两个面距离
        
        
      
        var polyonStr = ""
        for coords in coordinates {
            polyonStr = polyonStr + String(format: "%lf", coords.coordinate.latitude) + " " + String(format: "%lf", coords.coordinate.longitude) + ","
        }

        polyonStr.remove(at: polyonStr.index(before: polyonStr.endIndex))
        polyonStr = "(" + polyonStr + ")"
        polyonStr = "POLYGON(" + polyonStr + ")"

        let polygon = try! Geometry(wkt: polyonStr)
        let point = Point(x: mainLocation.coordinate.latitude, y: mainLocation.coordinate.longitude)
        //            try! polygon.intersects(polygon1)

        return try! polygon.distance(to: point)
        
        
//        var array = [CLLocationCoordinate2D]()
//        for coord in coordinates {
//            
//            array.append(coord.coordinate)
//            
//        }
//        var tempArr = [CLLocationCoordinate2D]()
//        tempArr.append(array.first!)
//        tempArr.append(array.last!)
//        let line = Turf.LineString(tempArr)
//        let point = line.closestCoordinate(to: CLLocationCoordinate2DMake(mainLocation.coordinate.latitude, mainLocation.coordinate.longitude))
//        print(point)
        
//        double length = [self.Calculates calculatWidthWithCoordinates:tempArr];
//
//        for (int i = 0; i < points.count - 1; i++)
//        {
//            NSArray<CLLocation *> * tempArrs = [NSArray arrayWithObjects:points[i],points[i+1], nil];
//            length += [self.Calculates calculatWidthWithCoordinates:tempArrs];
//        }
//        let line = Turf.LineString(array)
//        line.closestCoordinate(to: CLLocationCoordinate2DMake(mainLocation.coordinate.latitude, mainLocation.coordinate.longitude))
    }
    
    public func calculatPolygonCoverPoint(coordinates:Array<CLLocation>,pointLocation:CLLocation) -> Bool    {//点是否在面上

      
        var polyonStr = ""
        for coords in coordinates {
            polyonStr = polyonStr + String(format: "%lf", coords.coordinate.latitude) + " " + String(format: "%lf", coords.coordinate.longitude) + ","
        }
        
        polyonStr.remove(at: polyonStr.index(before: polyonStr.endIndex))
        polyonStr = "(" + polyonStr + ")"
        polyonStr = "POLYGON(" + polyonStr + ")"

        let polygon = try! Geometry(wkt: polyonStr)
        let point = Point(x: pointLocation.coordinate.latitude, y: pointLocation.coordinate.longitude)

        return try! polygon.contains(point)

    }
    public func calculatPolygonCoverPolygon(fatherCoordinates:Array<CLLocation>,sonCoordinates:Array<CLLocation>) -> Bool    {//面是否在面上

      
        var polyonStr = ""
        var sonPolyonStr = ""
        for coords in fatherCoordinates {
            polyonStr = polyonStr + String(format: "%lf", coords.coordinate.latitude) + " " + String(format: "%lf", coords.coordinate.longitude) + ","
            
        }
        for coords in sonCoordinates {
            sonPolyonStr = sonPolyonStr + String(format: "%lf", coords.coordinate.latitude) + " " + String(format: "%lf", coords.coordinate.longitude) + ","
        }
        polyonStr.remove(at: polyonStr.index(before: polyonStr.endIndex))
        polyonStr = "(" + polyonStr + ")"
        polyonStr = "POLYGON(" + polyonStr + ")"
        let polygon = try! Geometry(wkt: polyonStr)
        
        sonPolyonStr.remove(at: sonPolyonStr.index(before: sonPolyonStr.endIndex))
        sonPolyonStr = "(" + sonPolyonStr + ")"
        sonPolyonStr = "POLYGON(" + sonPolyonStr + ")"
        let sonPolygon = try! Geometry(wkt: sonPolyonStr)
  
        return try! polygon.contains(sonPolygon)

    }
    
    public func calculatTopologicallyEquivalent(coordinates:Array<CLLocation>) -> Bool    {//面是否有交叉点

        var polyonStr = ""
        for coords in coordinates {
            polyonStr = polyonStr + String(format: "%lf", coords.coordinate.latitude) + " " + String(format: "%lf", coords.coordinate.longitude) + ","
            
        }
        
        polyonStr.remove(at: polyonStr.index(before: polyonStr.endIndex))
        polyonStr = "(" + polyonStr + ")"
        polyonStr = "POLYGON(" + polyonStr + ")"

        let polygon =   try! Geometry(wkt: polyonStr)
        let polyon1 = try?  polygon.makeValid()
       

        return try! polygon.isTopologicallyEquivalent(to: polyon1)

    }
    
    public func calculatPolyonDisjoint(coordinates:Array<CLLocation>,coordinates1:Array<CLLocation>) -> Bool    {//两个面是否有相交

        var polyonStr = ""
        for coords in coordinates {
            polyonStr = polyonStr + String(format: "%lf", coords.coordinate.latitude) + " " + String(format: "%lf", coords.coordinate.longitude) + ","
            
        }
        polyonStr.remove(at: polyonStr.index(before: polyonStr.endIndex))
        polyonStr = "(" + polyonStr + ")"
        polyonStr = "POLYGON(" + polyonStr + ")"
        
        var polyonStr1 = ""
        for coords in coordinates1 {
            polyonStr1 = polyonStr1 + String(format: "%lf", coords.coordinate.latitude) + " " + String(format: "%lf", coords.coordinate.longitude) + ","
            
        }
        polyonStr1.remove(at: polyonStr1.index(before: polyonStr1.endIndex))
        polyonStr1 = "(" + polyonStr1 + ")"
        polyonStr1 = "POLYGON(" + polyonStr1 + ")"

        let polygon =   try! Geometry(wkt: polyonStr)
        let polyon1 = try! Geometry(wkt: polyonStr1)

        return try! polygon.intersects(polyon1)

    }
    
    
}
