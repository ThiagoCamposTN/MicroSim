import math

# a           = 172
# b           = 180
# operando    = 2

a           = 0xac
b           = 0xb4
operando    = 3

print("---")
print(f"a: dec({a}) hex({hex(a)}) bin({bin(a)})")
print(f"b: dec({b}) hex({hex(b)}) bin({bin(b)})")

# alu_a = (a << 8) + b
alu_a = (b << 8) + a
alu_b = operando
print("---")
print(f"alu_a: dec({alu_a}) hex({hex(alu_a)}) bin({bin(alu_a)})")
print(f"alu_b: dec({alu_b}) hex({hex(alu_b)}) bin({bin(alu_b)})")

dividendo   = alu_a
divisor     = alu_b
quociente   = math.floor(dividendo / divisor)
resto       = dividendo % divisor

print("---")
print(f"quociente: dec({quociente}) hex({hex(quociente)}) bin({bin(quociente)})")
print(f"resto: dec({resto}) hex({hex(resto)}) bin({bin(resto)})")

# alu_saida = ((quociente >> 8) << 8) + resto
alu_saida = ((quociente & 0x00FF) << 8) + resto
print(f"alu_saida: dec({alu_saida}) hex({hex(alu_saida)}) bin({bin(alu_saida)})")

a = alu_saida >> 8
b = resto

print("---")
print(f"a: dec({a}) hex({hex(a)}) bin({bin(a)})")
print(f"b: dec({b}) hex({hex(b)}) bin({bin(b)})")