# =========================
# Fixed-point helpers
# =========================

def sat_signed(val, bits):
    min_v = -(1 << (bits - 1))
    max_v = (1 << (bits - 1)) - 1
    return max(min(val, max_v), min_v)

def to_int16(val):
    return sat_signed(val, 16)

def to_int21(val):
    return sat_signed(val, 21)

# =========================
# FIR HW-accurate model
# =========================

def fir_hw_model(samples, coeffs, ile_probek, ile_wsp):
    """
    samples, coeffs: list[int]  -> int16 Q1.15
    return: list[int]           -> int16 Q1.15
    """

    out = []

    for n in range(ile_probek + ile_wsp - 1):
        acc = 0  # 21-bit accumulator (Q1.15)

        for k in range(ile_wsp):
            x_idx = n - k
            if 0 <= x_idx < ile_probek:

                # 16b x 16b -> 31b signed
                prod = samples[x_idx] * coeffs[k]

                # wybór bitów [30:15] -> Q1.15
                mul_q15 = prod >> 15

                # akumulacja (21 bit)
                acc += mul_q15
                acc = to_int21(acc)

        # wyjście: 21b -> 16b Q1.15
        y = to_int16(acc)
        out.append(y)

    return out
