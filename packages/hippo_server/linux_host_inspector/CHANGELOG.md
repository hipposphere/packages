## 0.3.0

- Report per-core CPU usage from `/proc/stat` over the same sampling window as
  the aggregate value (`LinuxSystemMetrics.cpuCoreUsagePercents`).
- Report a memory breakdown (`MemFree`, `Buffers + Cached + SReclaimable`, and
  derived process memory) on `LinuxMemoryUsage`; all new fields are optional.

## 0.2.1

- Read the hostname from the inspected root filesystem so containerized
  inspection is not affected by the container UTS namespace.

## 0.2.0

- Add lightweight aggregate system metrics with configurable procfs and root
  filesystem paths for containerized host inspection.

## 0.1.0

- Add typed host, CPU, memory, swap, load, disk, mount, network, and process inspection.
- Add counter-based CPU and throughput sampling.
- Add narrow libc bindings for filesystem capacity and system constants.
