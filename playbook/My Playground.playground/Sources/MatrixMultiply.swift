import Accelerate

// scalar

public func *(lhs: Matrix, rhs: Double) -> Matrix {
    return Matrix(rows: lhs.rows, columns: lhs.columns, elements: lhs.elements.map { $0*rhs })
}

public func *(lhs: Double, rhs: Matrix) -> Matrix {
    return rhs * lhs
}

// matmul

public func *(lhs: Matrix, rhs: Matrix) -> Matrix {
    precondition(lhs.columns == rhs.rows, "Matrices can't multiply.")
    let m = lhs.rows
    let n = rhs.columns
    let k = lhs.columns
    let lda = k
    let ldb = n
    let cElements = UnsafeMutablePointer<Double>.allocate(capacity: m*n)
    defer { cElements.deallocate(capacity: m*n) }
    cblas_dgemm(
        CblasRowMajor,                                // Order
        CblasNoTrans,                                 // TransA
        CblasNoTrans,                                 // TransB
        Int32(m),                                     // M
        Int32(n),                                     // N
        Int32(k),                                     // K
        1.0,                                          // alpha
        lhs.elements,                                 // A
        Int32(lda),                                   // lda
        rhs.elements,                                 // B
        Int32(ldb),                                   // ldb
        1.0,                                          // beta
        cElements, // C
        Int32(n)                                      // ldc
    )
    return Matrix(rows: m,
                  columns: n,
                  elements: Array(UnsafeBufferPointer(start: cElements, count: m*n)))
}