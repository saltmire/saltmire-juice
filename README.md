# Saltmire Juice — Game Feel Kit for Godot 4

A tiny, free (MIT) drop-in kit for the little effects that make a game feel good.
No dependencies, no editor bloat — one autoload with a clean API.

Built for Godot **4.6+**. Extracted and generalized from the
[Saltmire Survivors Template](https://saltmire.itch.io/survivors-template-godot).

## What's inside

| Call | Effect |
|------|--------|
| `Juice.shake(camera, amount)` | Trauma-based screen shake (small hits subtle, big hits punch) |
| `await Juice.hitstop(duration)` | Hit-stop / freeze-frame on impact |
| `Juice.flash(node, color)` | Flash a sprite/canvas item and fade back |
| `Juice.pop(node)` | Elastic scale punch |
| `Juice.damage_number(parent, pos, value, options)` | Pooled floating damage numbers |

## Install

1. Copy the `addons/saltmire_juice` folder into your project.
2. **Project → Project Settings → Plugins →** enable **Saltmire Juice**
   (this registers the `Juice` autoload). Done.

## Examples

```gdscript
# screen shake on a Camera2D — call it as many times as you like, trauma stacks
Juice.shake($Camera2D, 0.6)

# freeze the frame briefly on a big hit
await Juice.hitstop(0.08)

# white hit-flash on a sprite
Juice.flash($Sprite2D)

# floating damage number
Juice.damage_number(self, global_position + Vector2(0, -40), 25,
    {"color": Color.YELLOW, "scale": 1.4})

# juicy scale pop on pickup
Juice.pop($Icon)
```

Run the included `demo/demo.tscn` to see everything (it auto-plays; click to punch).

## Notes

- Screen shake writes `camera.offset` and `camera.rotation` while active.
- `hitstop` uses `Engine.time_scale`; nested calls are safe (the latest wins).
- Damage numbers are pooled, so spamming them is cheap.

## License

MIT — use it in anything, commercial or not. See `LICENSE.txt`.

Made by **Saltmire** · [saltmire.itch.io](https://saltmire.itch.io)
