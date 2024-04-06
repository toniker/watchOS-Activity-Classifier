import Foundation
import CoreML

extension MLMultiArray {
    /// All values will be stored in the last dimension of the MLMultiArray (default is dims=1)
    static func from(_ arr: [Double], dims: Int = 1) -> MLMultiArray {
        var shape = Array(repeating: 1, count: dims)
        shape[shape.count - 1] = arr.count
        /// Examples:
        /// dims=1 : [arr.count]
        /// dims=2 : [1, arr.count]
        ///
        let o = try! MLMultiArray(shape: shape as [NSNumber], dataType: .double)
        let ptr = UnsafeMutablePointer<Double>(OpaquePointer(o.dataPointer))
        for (i, item) in arr.enumerated() {
            ptr[i] = Double(item)
        }
        return o
    }

    /// This will concatenate all dimensions into one one-dim array.
    static func toIntArray(_ o: MLMultiArray) -> [Int] {
        var arr = Array(repeating: 0, count: o.count)
        let ptr = UnsafeMutablePointer<Int32>(OpaquePointer(o.dataPointer))
        for i in 0..<o.count {
            arr[i] = Int(ptr[i])
        }
        return arr
    }

    /// This will concatenate all dimensions into one one-dim array.
    static func toDoubleArray(_ o: MLMultiArray) -> [Double] {
        var arr: [Double] = Array(repeating: 0, count: o.count)
        let ptr = UnsafeMutablePointer<Double>(OpaquePointer(o.dataPointer))
        for i in 0..<o.count {
            arr[i] = Double(ptr[i])
        }
        return arr
    }

    /// This will concatenate all dimensions into one one-dim array.
    static func toFloat32Array(_ o: MLMultiArray) -> [Float32] {
        var arr: [Float32] = Array(repeating: 0, count: o.count)
        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(o.dataPointer))
        for i in 0..<o.count {
            arr[i] = Float32(ptr[i])
        }
        return arr
    }

    /// Helper to construct a sequentially-indexed multi array,
    /// useful for debugging and unit tests
    /// Example in 3 dimensions:
    /// ```
    /// [[[ 0, 1, 2, 3 ],
    ///   [ 4, 5, 6, 7 ],
    ///   [ 8, 9, 10, 11 ]],
    ///  [[ 12, 13, 14, 15 ],
    ///   [ 16, 17, 18, 19 ],
    ///   [ 20, 21, 22, 23 ]]]
    /// ```
    static func testTensor(shape: [Int]) -> MLMultiArray {
        let arr = try! MLMultiArray(shape: shape as [NSNumber], dataType: .double)
        let ptr = UnsafeMutablePointer<Double>(OpaquePointer(arr.dataPointer))
        for i in 0..<arr.count {
            ptr.advanced(by: i).pointee = Double(i)
        }
        return arr
    }
}

