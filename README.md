# react-native-screens: `setSize` on every Screen clone forces a full layout pass per scroll frame (Android, Fabric)

Minimal reproduction for [software-mansion/react-native-screens#4777](https://github.com/software-mansion/react-native-screens/issues/4777).

Two Expo Router tabs, each a plain `ScrollView` with 150 static rows. Nothing re-renders while scrolling, yet the JS thread spends most of its time laying out and pixel-rounding the whole shadow tree.

## Versions

- react-native-screens 4.26.2 (same code in 4.28.0 and on `main`, `rnscreens/legacy/RNSScreenComponentDescriptor.h`)
- react-native 0.86.3 (New Architecture), Hermes
- Expo SDK 57, expo-router 57.0.24
- Android emulator, Pixel 7, API 34, release build

## Run it

```sh
npm install
npx expo run:android --variant release
```

Then scroll the first tab, open the second tab so it mounts, go back and scroll again.

## Measure it

On a rooted emulator (`adb root`):

```sh
./profile.sh
```

It scrolls six times, prints the JS thread CPU time and the share of the relevant symbols from `simpleperf`.

## Results

JS thread (`mqt_v_js`) during six swipes:

| | CPU time | `flushStateUpdates` | `layoutTree` | `fmod` |
| --- | --- | --- | --- | --- |
| 4.26.2, only tab A mounted | 220 ms | 81% | 59% | 51% |
| 4.26.2, both tabs mounted | 390 ms | 87% | 73% | 63% |
| with the guard, only tab A mounted | 80 ms | 44% | not in profile | not in profile |
| with the guard, both tabs mounted | 100 ms | 46% | not in profile | not in profile |

The cost grows with everything mounted in the app, not with what is on screen.

## Cause

`RNSScreenComponentDescriptor::adopt` runs on every clone of a Screen shadow node and calls `setSize` without checking whether the size changed. `YogaLayoutableShadowNode::setSize` always marks the Yoga node dirty, so `RootShadowNode::layoutIfNeeded` runs `layoutTree` and `roundLayoutResultsToPixelGrid` over the whole tree.

On Android the native `ScrollView` pushes its content offset to the shadow tree on every scroll change (`ReactScrollViewHelper.updateStateOnScrollChanged`). That state update clones the path up to the root, through the Screen, once per scroll frame.

Screens inside JS bottom tabs have `frameSize == 0x0`, so they hit the `setSize({YGUndefined, YGUndefined})` branch on every clone.

## The guard

`fix/react-native-screens+4.26.2.patch` only calls `setSize` when the size actually changes:

```sh
patch -p1 < fix/react-native-screens+4.26.2.patch
npx expo run:android --variant release
```
