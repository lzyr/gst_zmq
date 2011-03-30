Object subclass: Point [
    | x y |

    Point class >> new: newX y: newY [
        | this |

        this := super new.
        this x: newX; y: newY.
        ^this
    ]

    x: anInt [
        x := anInt.
    ]

    x [
        ^x.
    ]

    y: anInt [
        y := anInt.
    ]

    y [
        ^y.
    ]
]

