# ITLab FPGA practice

Шаблонный репозиторий для разработки и верификации цифрового аппаратного обеспечения на SystemVerilog с использованием CMake, Verilator и Google Test.

## Структура проекта

*   `src/` — файлы синтезируемых модулей.
*   `tb/` — тестовые стенды на C++ для Verilator.
*   `.github/workflows/` — конфигурация CI.

## Установка зависимостей (WSL)
```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake verilator libgtest-dev git
```

## Сборка

```bash
cmake -B build
cmake --build build -j8
```

## Запуск тестов и просмотр временных диаграмм

```bash
cd build
ctest --output-on-failure
```
или
```bash
./build/tb/test_xxxx
```
Временные диаграммы --- в `/build/tb/dump_xxxx.vcd"