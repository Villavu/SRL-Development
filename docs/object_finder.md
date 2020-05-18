### About TRSObjectFinder

---
#### Zoom

When designing a object finder you should be at **default zoom(50)** in the **fixed** client mode. This allows the finder to work at any zoom and client mode when made. The `MainScreen.ConvertDistance` method makes this possible.

A finder working at two different zoom levels, producing similar results without having to change any variables:

![img](images/zoom.png)

---

#### TRSObjectFinder.Colors

A color array which will be merged together, use ACA to acquire color(s).

```pascal
Finder.Colors += CTS2(2503237, 20, 0.10, 0.14); // brown
Finder.Colors += CTS2(5526875, 15, 0.19, 0.06); // grey
```

The two colors above found and merged together:

![img](images/color_array.png)

---

#### TRSObjectFinder.ColorClusters

A array of "color clusters" which will be merged together, use ACA to acquire color(s).

A color cluster consists of a `primary` and `secondary` color and a `distance` value.
When searched for only `primary` colors within `distance` of `secondary` colors are returned.

```pascal
// Only brown within 2 pixels of grey will be found.
Finder.ColorClusters += [
  CTS2(2503237, 20, 0.10, 0.14), // brown
  CTS2(5526875, 15, 0.19, 0.06), // grey
  2				 // distance			
];                        
```

The above color cluster found:

![img](images/color_cluster.png)

---

#### TRSObjectFinder.Erode

The amount to erode before clustering. This is useful for removing small amounts of noise.

```pascal
Finder.Erode := 2;
```

`Erode=0`

![img](images/no_erode.png)

`Erode=2`

![img](images/erode.png)

---

#### TRSObjectFinder.Grow

The amount to grow before eroding. This is useful for filling gaps.

```pascal
Finder.Grow := 2;
```

`Grow=0`

![img](images/grow_before.png)

`Grow=3`

![img](images/grow_after.png)

Paired with eroding:
`Grow=3`
`Erode=4`

![img](images/grow_erode.png)

---

#### TRSObjectFinder.ClusterDistance

The distance to pass to `ClusterTPA`, this is how we split up multiple objects. `Distance=5` would mean that points that are closer than or equal to 5 pixels away are considered close enough to merge into a singular group.

`ClusterDistance=5` Four individual chairs:

![img](images/cluster_five.png)

`ClusterDistance=20` Two sets of chairs:

![img](images/cluster_twenty.png)

---

#### Filtering By Size 

```pascal
TRSObjectFinder.MinLongSide 
TRSObjectFinder.MaxLongSide 
TRSObjectFinder.MinShortSide 
TRSObjectFinder.MaxShortSide
```

These are the size limits that can be set, any object that exceeds these will be removed. The bounding rectangle is found which has a `long` and a `short` side measured in pixels.

```pascal
// Removes objects where the short side isn't within `10..20`
Finder.MinShortSide := 10;
Finder.MaxShortSide := 20;
// Removes objects where the long side isn't within `20..40`
Finder.MinLongSide := 20;
Finder.MaxLongSide := 40; 
```

An example bounding rectangle: 

![img](images/bounding_rect.png)
