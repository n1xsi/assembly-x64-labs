# Лабораторная работа №2: Условные ветвления.
# Задание: Если сумма целых чисел А, В и С меньше единицы, то наименьшее из этих трёх чисел заменить суммой двух других.

### Определение точки входа в программу
.global _start

### Секция данных (константы)
.data
prompt_msg: .asciz "Input A, B, C (separate by SPACE): "
initial_msg: .asciz "Initial values: A = %lld, B = %lld, C = %lld\n"
final_msg:   .asciz "Final values:   A = %lld, B = %lld, C = %lld\n"
input_fmt:   .asciz "%lld %lld %lld"  # %lld - long long signed decimal (int64_t)

### Секция кода
.text

## Точка входа в программу
_start:
    # Выделение 32 байтов для сохранения 16-байтного выравнивания стека (для функций printf, scanf)  
    # RSP -> [ C ]
    # RSP+8 -> [ B ]
    # RSP+16 -> [ A ]
    # RSP+24 -> [ padding ]
    subq $32, %rsp

    # Ввод чисел A, B, C
    leaq prompt_msg(%rip), %rdi
    xor %eax, %eax
    call printf

    leaq input_fmt(%rip), %rdi
    leaq 16(%rsp), %rsi             # Адрес для A
    leaq 8(%rsp), %rdx              # Адрес для B
    movq %rsp, %rcx                 # Адрес для C
    xor %eax, %eax                  # Для scanf с variadic args нужно обнулить %rax
    call scanf

    # Загрузка введённых значений из стека в регистры
    movq 16(%rsp), %r12             # r12 = A
    movq 8(%rsp), %r13              # r13 = B
    movq (%rsp), %r14               # r14 = C

    # Вывод начальных значений
    leaq initial_msg(%rip), %rdi
    movq %r12, %rsi                 # A
    movq %r13, %rdx                 # B
    movq %r14, %rcx                 # C
    xor %eax, %eax
    call printf

    # Вычисление суммы
    movq %r12, %rax                 # rax = A
    addq %r13, %rax                 # rax = A + B
    addq %r14, %rax                 # rax = A + B + C

    # Проверка условия: Сумма чисел < 1
    cmpq $1, %rax
    jge skip_modification           # Если сумма >= 1, пропуск всех изменений

    # Блок модификации:
    # Если сумма < 1, то начинается поиск наименьшего числа
    # r15 будет хранить указатель на наименьшее число на стеке
    # rbx будет хранить значение наименьшего числа
    movq %r12, %rbx                 # Допустим, что A - наименьшее
    leaq 16(%rsp), %r15             # r15 = адрес A

    cmpq %r13, %rbx                 # Сравнивание min (A) с B
    jle check_vs_C                  # Если A <= B, то min пока не меняется
    movq %r13, %rbx                 # Иначе B - новый минимум
    leaq 8(%rsp), %r15              # r15 = адрес B

## Сравнение min с C
check_vs_C:
    cmpq %r14, %rbx                 # Сравнивание текущего min с C
    jle do_replacement              # Если min <= C, минимум найден
    movq %r14, %rbx                 # Иначе C - новый минимум
    movq %rsp, %r15                 # r15 = адрес C

## Замена наименьшего значения
do_replacement:
    # Вычисляение суммы двух других чисел = (A+B+C) - min = %rax - %rbx
    # (В %r15 - минимальное число, общая сумма чисел в %rax)
    subq %rbx, %rax                 # Теперь rax содержит сумму двух других чисел
    movq %rax, (%r15)               # Эта сумма записывается по адресу в %r15, заменяя минимум

    # Обновляение регистров r12, r13, r14
    movq 16(%rsp), %r12             # r12 = A
    movq 8(%rsp), %r13              # r13 = B
    movq (%rsp), %r14               # r14 = C

## Конец блока модификации (переход к выводу)
skip_modification:
    # Вывод конечных значений
    leaq final_msg(%rip), %rdi
    movq %r12, %rsi
    movq %r13, %rdx
    movq %r14, %rcx
    xor %eax, %eax
    call printf

    # Завершение программы
    addq $32, %rsp                  # Очистка 32-байтного стека
    movq $60, %rax                  # sys_exit
    xor %rdi, %rdi                  # Код возврата 0
    syscall                         # Завершение процесса
