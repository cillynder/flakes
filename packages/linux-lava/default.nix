{ buildLinux
, callPackage
, inputs
, lib
, linuxLavaEnv
, useCcache ? false
, ...
} @ args:

let
  sources = callPackage ./sources.nix { inherit inputs; };
  kernel = buildLinux (args // {
    inherit (sources) src kernelPatches;
    stdenv = if useCcache then linuxLavaEnv.ccacheStdenv else linuxLavaEnv.stdenv;
    version = "${sources.version}-tkg-Lava";
    isZen = true;
    extraMakeFlags = [ "LLVM=1" "LLVM_IAS=1" ];
    # TODO:
    # some stuff is set in pkgs/os-specific/linux/kernel/common-config.nix
    # but i have no idea how to change it
    structuredExtraConfig = with lib.kernel; builtins.mapAttrs (_: value: lib.mkForce value) {
      LOCALVERSION = freeform "-tkg-Lava";
      ZENIFY = yes;
      WINESYNC = module;

      #tkg defaults
      DYNAMIC_FAULT = no;
      DEFAULT_FQ_CODEL = no;
      WERROR = no;
      NTP_PPS = no;
      ZSWAP_COMPRESSOR_DEFAULT_LZO = no;
      PROFILE_ALL_BRANCHES = no;
      CRYPTO_LZ4 = yes;
      CRYPTO_LZ4HC = yes;
      LZ4_COMPRESS = yes;
      LZ4HC_COMPRESS = yes;
      ZSWAP_COMPRESSOR_DEFAULT_LZ4 = yes;
      ZSWAP_COMPRESSOR_DEFAULT_ZSTD = no;
      DEBUG_FORCE_FUNCTION_ALIGN_64B = no;
      X86_P6_NOP = no;
      RCU_STRICT_GRACE_PERIOD = no;
      ZSWAP_COMPRESSOR_DEFAULT = freeform "lz4";
      CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = yes;
      CPU_FREQ_DEFAULT_GOV_ONDEMAND = no;
      CPU_FREQ_DEFAULT_GOV_CONSERVATIVE = no;
      CPU_FREQ_DEFAULT_GOV_PERFORMANCE = no;
      CPU_FREQ_DEFAULT_GOV_PERFORMANCE_NODEF = no;
      BLK_DEV_LOOP = module;
      I2C_NCT6775 = module; # openrgb

      # clang/llvm
      LTO_CLANG_FULL = no;
      LTO_CLANG_THIN = yes;
      LTO_NONE = no;
      KCSAN = no;
      INIT_ON_FREE_DEFAULT_ON = yes;
      INIT_STACK_ALL_ZERO = yes;
      INIT_STACK_NONE = no;

      # bore
      SCHED_BORE = yes;
      MIN_BASE_SLICE_NS = freeform "2000000";

      # tickless timers
      HZ_PERIODIC = no;
      NO_HZ = yes;
      NO_HZ_COMMON = yes;
      NO_HZ_FULL = yes;
      NO_HZ_FULL_NODEF = yes;
      NO_HZ_IDLE = no;
      TICK_CPU_ACCOUNTING = no;
      VIRT_CPU_ACCOUNTING_GEN = yes;
      CONTEXT_TRACKING = yes;
      CONTEXT_TRACKING_FORCE = no;
      HZ_1000 = yes;
      HZ_1000_NODEF = yes;

      # preempt
      PREEMPT = yes;
      PREEMPT_COUNT = yes;
      PREEMPT_LAZY = no;
      PREEMPT_VOLUNTARY = no;
      PREEMPTION = yes;
      PREEMPT_DYNAMIC = yes;

      # disable numa
      NUMA = no;
      AMD_NUMA = no;
      ACPI_NUMA = no;
      X86_64_ACPI_NUMA = no;
      NODES_SPAN_OTHER_NODES = no;
      NUMA_EMU = no;
      NODES_SHIFT = no;
      NEED_MULTIPLE_NODES = no;
      USE_PERCPU_NUMA_NODE_ID = no;

      # disable ftrace
      FUNCTION_TRACER = no;
      FUNCTION_GRAPH_TRACER = no;

      # disable misc debugging
      SLUB_DEBUG = no;
      PM_DEBUG = no;
      PM_ADVANCED_DEBUG = no;
      PM_SLEEP_DEBUG = no;
      ACPI_DEBUG = no;
      SCHED_DEBUG = no;
      LATENCYTOP = no;
      DEBUG_PREEMPT = no;
    };
    ignoreConfigErrors = true;
  } // (args.argsOverride or {}));
in kernel.overrideAttrs(old: {
  # :sob: see https://github.com/NixOS/nixpkgs/issues/37249
  passthru = kernel.passthru;
  hardeningDisable = (old.hardeningDisable or []) ++ [ "strictoverflow" ];
})
