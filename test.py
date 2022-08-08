import unittest
import cpu
from cpu import CPU

class TestStringMethods(unittest.TestCase):

    def test_escrever_na_memoria(self):
        comandos = [0x20, 8,            # LDA # 8
                    0x60, 6,            # LDB # 6
                    0x48,               # ABA
                    0x58, 0x12, 0x00]   # CAL EXIT

        cpu.escrever_na_memoria(0x100, comandos)

        self.assertEqual(CPU.memoria[0x100], 0x20)
        self.assertEqual(CPU.memoria[0x101], 0x08)
        self.assertEqual(CPU.memoria[0x102], 0x60)
        self.assertEqual(CPU.memoria[0x103], 0x06)
        self.assertEqual(CPU.memoria[0x104], 0x48)
        self.assertEqual(CPU.memoria[0x105], 0x58)
        self.assertEqual(CPU.memoria[0x106], 0x12)
        self.assertEqual(CPU.memoria[0x107], 0x00)

    def test_lda_direto(self):
        comandos = [0x20, 8]    # LDA # 8

        cpu.escrever_na_memoria(0x100, comandos)

        self.assertEqual(CPU.registrador_a, 0x00)

        cpu.executar_comando(0x100)

        self.assertEqual(CPU.registrador_a, 0x08)
    
    def test_ldb_direto(self):
        comandos = [0x60, 6]    # LDB # 6

        cpu.escrever_na_memoria(0x100, comandos)

        self.assertEqual(CPU.registrador_b, 0x08)

        cpu.executar_comando(0x100)

        self.assertEqual(CPU.registrador_b, 0x06)

if __name__ == '__main__':
    unittest.main()
