┌───────────────┐
                          │  Admin Panel  │
                          │  Global Map   │
                          │  Farm Layers  │
                          └───────┬───────┘
                                  │
                                  │ API / Monitoring
                                  │
                  ┌───────────────┴───────────────┐
                  │         Server / Docker       │
                  │  Plugin Repository / LSPs    │
                  │  Farm Aggregation / Logging  │
                  └───────────────┬───────────────┘
                                  │
        ┌─────────────────────────┴─────────────────────────┐
        │                                                 │
        │                 Base Pi Zero Cluster            │
        │                                                 │
┌───────┴───────┐   ┌───────┴───────┐   ┌───────┴───────┐
│ Node 1 (API)  │   │ Node 2 (API)  │   │ Nodes 3-10    │
│ Dual-Process  │   │ Dual-Process  │   │ Compute Nodes │
│ Worker 0-?   │   │ Worker 0-?   │   │ Dual-Process  │
└──────────────┘   └──────────────┘   └───────────────┘
                        │
                        │ Relay Nodes / Worker Coordination
                        │
                   ┌───────┴───────┐
                   │ Nodes 11-12   │
                   │ Relay / Mirror│
                   └───────┬───────┘
                           │
      ┌────────────────────┴────────────────────┐
      │              Worker Pools               │
      │  36 workers distributed across nodes   │
      │  6 per dual-process, synchronized via  │
      │  Redux / Lodash                        │
      └────────────────────┬────────────────────┘
                           │
                           │ Aggregated Data for
                           │ Farm Layer / Global Map
           ┌───────────────┴────────────────┐
           │          Farm Layer             │
           │  University / State Centroids  │
           │  Obfuscated GPS per node       │
           │  Client Count Aggregation      │
           └───────────────┬────────────────┘
                           │
                           │ Up to 4 billion simulated clients
                           │ (via Simulator Module)
                           │
                 ┌─────────┴─────────┐
                 │  Global Client Map│
                 │  Visualized in    │
                 │  Admin Panel      │
                 └───────────────────┘
