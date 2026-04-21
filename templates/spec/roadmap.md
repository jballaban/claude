# Roadmap

Feature dependency graph. The `/build` skill reads this file to determine build order — what can be built now, what is blocked, and what becomes available after each merge.

Feature names must match the folder names in `spec/features/`. Branch names will be `feature/{name}`.

---

## Features

```yaml
features:

  - name: example-feature
    description: One-line description of what this feature does
    depends_on: []

  - name: another-feature
    description: One-line description
    depends_on: [example-feature]
```

---

## Notes

- `depends_on: []` means the feature can be built immediately (no dependencies)
- List only features whose *code* this feature directly depends on — not every feature that happens to ship before it
- Features with the same dependency set can be built in parallel
- `/build` uses GitHub merged branch state to determine what is "built" — a feature is built when `feature/{name}` has been merged into the default branch
