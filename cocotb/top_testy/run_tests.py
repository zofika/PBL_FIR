import os
import sys
import argparse
import shutil
from pathlib import Path

from cocotb_tools.runner import get_runner


def main() -> None:
    parser = argparse.ArgumentParser(description="Run cocotb tests for pbl_TOP")
    parser.add_argument("--testcase", default=os.getenv("TESTCASE"), help="Testcase name, e.g. top_test_1")
    parser.add_argument(
        "--waves",
        action="store_true",
        default=os.getenv("WAVES", "0") not in ("0", "false", "False", "no", "No"),
        help="Enable waveform dumping",
    )
    args = parser.parse_args()

    test_dir = Path(__file__).resolve().parent
    repo_root = test_dir.parents[1]
    src_dir = repo_root / "src"

    # So `modelFIR` import works the same way as in the tests.
    sys.path.insert(0, str(repo_root))
    # Make sure simulator-embedded Python can import from the repo and this test directory.
    pythonpath_parts = [str(test_dir), str(repo_root)]
    existing_pythonpath = os.environ.get("PYTHONPATH")
    if existing_pythonpath:
        pythonpath_parts.append(existing_pythonpath)
    os.environ["PYTHONPATH"] = os.pathsep.join(pythonpath_parts)

    verilog_sources = [
        src_dir / "pbl_TOP.sv",
        src_dir / "AXI_main.sv",
        src_dir / "axi.sv",
        src_dir / "ram.sv",
        src_dir / "multiplekser.sv",
        src_dir / "FIR_main.sv",
        src_dir / "fsm.sv",
        src_dir / "licznik.sv",
        src_dir / "licznik_petli.sv",
        src_dir / "shift_R.sv",
        src_dir / "multiplier.sv",
        src_dir / "adder.sv",
        src_dir / "acc.sv",
        src_dir / "APB_main.sv",
        src_dir / "cdc.sv",
        src_dir / "apb.sv",
        src_dir / "decoder.sv",
        src_dir / "rejestry_ster.sv",
    ]

    testcase = args.testcase  # e.g. top_test_1
    waves = args.waves

    # Common cocotb env knobs
    os.environ.setdefault("COCOTB_REDUCED_LOG_FMT", "1")
    if waves:
        os.environ.setdefault("COCOTB_TRACE", "1")
        os.environ.setdefault("COCOTB_SIM_VCD", "1")

    if shutil.which("iverilog") is None:
        raise SystemExit(
            "iverilog not found in PATH. Install Icarus Verilog and reopen the terminal/VS Code so PATH is refreshed."
        )

    runner = get_runner("icarus")
    runner.build(
        verilog_sources=[str(p) for p in verilog_sources],
        build_dir=str(test_dir / "sim_build"),
        build_args=["-g2012"],
        defines={"COCOTB_SIM": 1},
        hdl_toplevel="pbl_TOP",
        waves=waves,
        always=True,
    )

    runner.test(
        test_module="testy_top",
        hdl_toplevel="pbl_TOP",
        testcase=testcase,
        waves=waves,
        build_dir=str(test_dir / "sim_build"),
    )


if __name__ == "__main__":
    main()
