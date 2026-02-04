"""Auto-imported Python hook used by cocotb tests.

Do not modify test modules: provide compatibility shims here.
"""

# cocotb 2.x AXI reads may return cocotb.types.LogicArray objects.
# Some existing tests expect a handle-like API (`obj.value`).
# Add a small compatibility property so `int(obj.value)` keeps working.

try:
    from cocotb.types import LogicArray

    if not hasattr(LogicArray, "value"):

        @property  # type: ignore[misc]
        def value(self):  # noqa: D401
            return int(self.to_unsigned())

        LogicArray.value = value  # type: ignore[attr-defined]
except Exception:
    # If cocotb isn't available at import time, do nothing.
    pass
