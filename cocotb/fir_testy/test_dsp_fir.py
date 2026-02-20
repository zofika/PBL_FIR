import numpy as np
import matplotlib.pyplot as plt

# matplotlib.use("Agg")


class DSPfirTests:
    def impulse_response_diagram(self, y_wyn, label=None):
        # Plot the impulse response
        plt.figure(figsize=(10, 3))
        plt.stem(y_wyn)
        plt.title(f"Odpowiedź impulsowa filtra {label}")
        plt.xlabel("n")
        plt.ylabel("y[n]")
        plt.grid(True)
        plt.savefig("impulse_response_diagram.png")
        plt.close()

    def sinus_generator(self, f_sin=5, N=32):
        t = np.arange(N)
        sine_wave = np.round(32767 * np.sin(2 * np.pi * f_sin * t / N)).astype(int)
        return t, sine_wave

    def sinus_response_diagram(self, t, sine_wave, y_wyn, label=None):
        # Plot the sinusoidal response
        t_out = np.arange(len(y_wyn))

        plt.figure()
        plt.plot(t, sine_wave, label="Wejście (sin)")
        plt.plot(t_out, y_wyn, label=f"Wyjście filtru {label}")
        plt.title("Odpowiedź FIR na sinusoidę")
        plt.xlabel("n")
        plt.ylabel("Amplituda")
        plt.legend()
        plt.grid(True)
        plt.savefig(f"sinus_response_diagram_of_{label}.png")
        plt.close()

    def frequency_response(self, coeffs):
        H = np.fft.fft(coeffs, 512)  # zeros up to 512 for smoother digram
        H = H[:256]
        f = np.linspace(0, 1, 256)  # frequency normalized 0..1
        w = np.linspace(0, 2 * np.pi, len(H))
        return w, f, H

    def frequency_response_diagram(self, coeffs, label=None):
        w, f, H = self.frequency_response(coeffs)

        plt.figure(figsize=(10, 4))

        plt.subplot(2, 1, 1)
        plt.plot(f, (np.abs(H)))
        plt.title(f"Charakterystyka amplitudowa filtra {label}")
        plt.xlabel("Normalizowana częstotliwość")
        plt.ylabel("Amplituda")
        plt.grid(True)

        plt.subplot(2, 1, 2)
        plt.plot(f, np.angle(H))
        plt.title(f"Charakterystyka fazowa filtra {label}")
        plt.xlabel("Normalizowana częstotliwość")
        plt.ylabel("Faza (radiany)")
        plt.grid(True)

        plt.tight_layout()
        plt.savefig(f"frequency_response_diagram_of_{label}.png")
        plt.close()

    def compute_delay(self, y, wyn, coeffs):
        wyn = np.array(wyn)
        y = np.array(y)

        corr = np.correlate(wyn, y, mode="full")
        delay = np.argmax(corr) - (len(y) - 1)

        if delay == 0:
            print(f"Liczę opóźnienie grupowe")
            w, f, H = self.frequency_response(coeffs)
            phase = np.angle(H)
            delay = -np.gradient(phase, w)
        else:
            print(f"Opóźnienie czasowe: {delay} próbek pomiędzy modelami filtrów")
        return delay

    def compare_responses(self, probki, y, wyn):
        t_in = np.arange(len(probki))
        t_out = np.arange(len(wyn))
        y = np.array(y)
        wyn = np.array(wyn)

        if np.array_equal(y, wyn):
            print("Odpowiedzi są identyczne ")
            plt.figure()
            plt.plot(t_in, probki, label="Wejście")
            plt.plot(t_out, wyn, label="Wyjście FIR")
            plt.title("FIR Projekt == Referencyjny")
            plt.legend()
            plt.grid()
            plt.savefig("filter_response_diagram.png")
            plt.close()
        else:
            print("Odpowiedzi różnią się ")
            plt.figure()
            plt.plot(t_in, probki, label="Wejście")
            plt.plot(t_out, y, label="Wyjście Referencyjne")
            plt.plot(t_out, wyn, label="Wyjście FIR")
            plt.title("FIR Projekt != Referencyjny")
            plt.legend()
            plt.grid()
            plt.savefig("filter_response_diagram.png")
            plt.close()
        return np.array_equal(y, wyn)
