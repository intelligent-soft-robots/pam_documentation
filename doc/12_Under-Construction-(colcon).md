see [Max's doc](https://github.com/machines-in-motion/machines-in-motion.github.io/wiki/use_colcon)

To build and run the unit-tests:

```bash
colcon test 
```

with verbose output:

```bash
colcon test --event-handlers console_direct+
```

for selected package(s):

```bash
colcon test --packages-select package_name --event-handlers console_direct+
```
