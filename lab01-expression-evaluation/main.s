# Лабораторная работа №1: Знаковые числа.
# Задание: Вычислить значение функции Y = (2*A^3 - 4*A^2)/B^2

### Определение точки входа в программу
.global _start

### Секция данных (константы)
.data
input_str:  .asciz "Input A and B (separate by SPACE): "
output_str: .asciz "Result Y = %.3f\n"  # %.3f - 3 знака после запятой
input_fmt:  .asciz "%lld %lld"          # %lld - long long signed decimal (int64_t)
error_str:  .asciz "Error: Division by zero!\n"

### Секция кода
.text

## Точка входа в программу
_start:
    # Буфер для ввода A и B (subq - substract quadword)
    subq $16, %rsp  # Выделение 16 байт в стеке (8 для A и 8 для B), уменьшаем %rsp (stack pointer)

    # Вывод "введите числа" (leaq - load effective address, %rip - instruction pointer, %rdi - destination index)
    leaq input_str(%rip), %rdi      # Аргумент 1: Адрес строки-приглашения
    xor  %eax, %eax                 # Для printf с variadic args нужно обнулить %rax (accumulator register)
    call printf                     # Вызов вывода printf из C Library

    # Ввод чисел A и B
    leaq input_fmt(%rip), %rdi      # Аргумент 1 для scanf: Адрес строки формата в %rdi
    movq %rsp, %rsi                 # Аргумент 2 для scanf: Адрес буфера для сохранения A (вершина стека, %rsi - source index)
    leaq 8(%rsp), %rdx              # Аргумент 3 для scanf: Адрес буфера для сохранения B (смещение +8 байт, %rdx - data register)
    xor  %eax, %eax                 # Для scanf с variadic args нужно обнулить %rax
    call scanf                      # Вызов функции для чтения двух чисел

    # Загрузка введённых A и B из стека в регистры
    movq (%rsp), %r8                # A в %r8
    movq 8(%rsp), %r9               # B в %r9

    # Проверка деления на ноль
    testq %r9, %r9                  # Проверяем, равен ли B нулю (быстрее, чем cmpq $0)
    jz division_by_zero             # Если B == 0, переходим к обработке ошибки (jz - jump if zero)

    # Вычисление числителя формулы
    # Подсчёт 2*A^3
    movq %r8, %rax                  # rax = A
    imulq %r8, %rax                 # rax = A*A = A^2  (imulq - integer multiplication quadword)
    imulq %r8, %rax                 # rax = A^2*A = A^3
    shlq $1, %rax                   # rax = A^3 * 2  (shlq - logical shift left quadword, сдвиг влево на 1 бит, эвкивалентно умножению на 2)

    # Подсчёт 4*A^2
    movq %r8, %rbx                  # rbx = A  (%rbx - base register)
    imulq %r8, %rbx                 # rbx = A*A = A^2
    shlq $2, %rbx                   # rbx = A^2 * 4

    # Вычитание одного из другого
    subq %rbx, %rax                 # rax = (2*A^3) - (4*A^2)

    # Вычисление знаменателя формулы
    # Подсчёт B^2
    movq %r9, %rbx                  # rbx = B
    imulq %r9, %rbx                 # rbx = B*B = B^2

    # Деление с плавающей точкой
    # Преобразуем числитель (из %rax) и знаменатель (из %rbx) в double (cvtsi2sdq - ConVerT Signed Integer TO Scalar Double-precision Quadword)
    cvtsi2sdq %rax, %xmm0           # xmm0 = (double)числитель
    cvtsi2sdq %rbx, %xmm1           # xmm1 = (double)знаменатель
    divsd %xmm1, %xmm0              # xmm0 = xmm0 / xmm1

    # Вывод результата
    leaq output_str(%rip), %rdi     # Аргумент 1: Адрес строки формата для printf
    movq $1, %rax                   # Аргумент 2: 1 SSE-регистр (%xmm0) используется для передачи значения
    call printf

    # Корректное завершение программы
    addq $16, %rsp                  # Освобождаем место в стеке
    movq $60, %rax                  # Код системного вызова для выхода (sys_exit)
    xor %rdi, %rdi                  # Возвращение 0 (успешное завершение)
    syscall                         # Вызов системной функции завершения

## Обработка ошибки деления на ноль
division_by_zero:
    leaq error_str(%rip), %rdi      # Аргумент 1: Адрес строки с ошибкой
    xor %eax, %eax                  # Обнуление %rax для printf
    call printf                     # Вызов printf для вывода ошибки

    movq $60, %rax                  # Код системного вызова для выхода
    movq $1, %rdi                   # Возвращение 1 (код ошибки)
    addq $16, %rsp                  # Освобождение стека перед выходом
    syscall                         # Завершение процесса
