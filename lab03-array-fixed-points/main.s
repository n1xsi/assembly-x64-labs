# Лабораторная работа №3: Косвенная адресация.
# Задание: Переписать из массива А в массив В те элементы массива А, индексы которых совпадают со значением (A[i] == i).

### Определение точки входа в программу
.global _start

### Секция данных (константы)
.data
    # Определение массива A
    array_A: .quad 1, 2, 3, 4, 5, 6, 7, 7, 7, 7, 7
    array_A_size: .quad 11

    # Место для массива B
    array_B: .space 8 * 11  # 11 элементов по 8 байт - выделение с запасом, равным размеру A
    array_B_size: .quad 0   # Переменная для хранения фактического количества элементов

    # Строки для вывода результатов
    msg_array_a:    .asciz "Array A: "
    msg_array_b:    .asciz "Array B (filtered): "
    element_format: .asciz "%ld "  # %ld - long decimal
    newline:        .asciz "\n"

### Секция кода
.text

## Точка входа в программу
_start:
    # Инициализация счётчиков и указателей
    movq $0, %r12           # r12 -> индекс 'i' для прохода по массиву A
    movq $0, %r13           # r13 -> индекс 'j' (и счётчик) для массива B

## Основной цикл обработки массива A
loop_start:
    # Проверка, не достигли ли пределы массива A
    cmpq %r12, array_A_size(%rip)  # Сравнивание i (в %r12) с размером A (cmpq - comare quadword)
    je loop_end                    # Если i == размер A, то цикл завершается (je - jump if equal)

    # Получение значения A[i] с помощью косвенной адресации (с масштабированием)
    # Формат: base_address(,%index_register, scale_factor)
    movq array_A(,%r12,8), %rax  # Адрес = array_A + r12 * 8

    # Проверка: A[i] == i?
    cmpq %r12, %rax           # Сравнивание i (в %r12) со значением A[i] (в %rax)
    jne next_iteration        # Если не равны - переход к следующему элементу (jne - jump if not equal)

    # Индекс совпадает со значением, копируем элемент A[i] в B[j]
    movq %rax, array_B(,%r13,8)  # Копирование B[j] = A[i] по адресу (array_B + r13 * 8)
    incq %r13                    # Увеличивание счётчика/индекса для B: j++ (incq - increment quadword)

next_iteration:
    incq %r12                 # Увеличение индекса для A: i++
    jmp loop_start            # Переход к следующей итерации (jmp - jump)

loop_end:
    # Сохранение итогового количества элементов B (j) в array_B_size
    movq %r13, array_B_size(%rip)

    # Вывод массива A
    leaq msg_array_a(%rip), %rdi  # leaq - load effective address quadword
    xor %eax, %eax
    call printf

    movq $0, %r12                 # Сброс счётчика i для цикла печати

print_A_loop:
    cmpq %r12, array_A_size(%rip)  # Сравнить i с array_A_size
    je print_A_end
    
    leaq element_format(%rip), %rdi
    movq array_A(,%r12,8), %rsi  # Второй аргумент printf (значение)
    xor %eax, %eax               # Обнуляение %rax перед вызовом printf
    call printf
    
    incq %r12                    # i++
    jmp print_A_loop
    
print_A_end:
    leaq newline(%rip), %rdi     # Переход на новую строку
    xor %eax, %eax
    call printf
    
    # Вывод массива B
    leaq msg_array_b(%rip), %rdi
    xor %eax, %eax
    call printf
    
    movq $0, %r12                # Сброс счётчика i для цикла печати

print_B_loop:
    # Используется фактический размер B, а не размер A, так как B может быть меньше !!!
    cmpq %r12, array_B_size(%rip)  # Сравнить i с array_B_size (фактическим размером)
    je print_B_end
    
    leaq element_format(%rip), %rdi
    movq array_B(,%r12,8), %rsi    # Второй аргумент printf (значение)
    xor %eax, %eax
    call printf
    
    incq %r12
    jmp print_B_loop
    
print_B_end:
    leaq newline(%rip), %rdi       # Переход на новую строку
    xor %eax, %eax
    call printf
    
    # Завершение программы
    addq $8, %rsp             # Восстанавление стека
    movq $60, %rax            # Системный вызов sys_exit
    xorq %rdi, %rdi           # Код возврата 0 (успех)
    syscall                   # Завершение процесса
