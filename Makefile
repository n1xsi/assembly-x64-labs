# Определение списка всех директорий с лабораторными работами:
LAB_DIRS = \
    lab01-expression-evaluation \
    lab02-conditional-branching \
    lab03-array-fixed-points \
    lab04-bitwise-pair-swap \
    lab05-byte-progression-check

# Объявление целей, которые не являются файлами
.PHONY: all clean $(LAB_DIRS) lab01 lab02 lab03 lab04 lab05

# Цель по умолчанию (если запустить 'make' без аргументов) - собрать всё
all: $(LAB_DIRS)

# Правило-шаблон для сборки каждой отдельной лабораторной
# При попытке "make lab01-expression-evaluation", make находит эту цель и выполняет команду
# $(MAKE) -C $@ рекурсивно вызывает make в директории $@
$(LAB_DIRS):
	@echo "##### Building lab: $@ #####"
	$(MAKE) -C $@

# Цель для очистки всех скомпилированных файлов - итерирует по всем директориям и запускает в каждой 'make clean'
clean:
	@for dir in $(LAB_DIRS); do \
		echo "----- Cleaning lab: $$dir -----"; \
		$(MAKE) -C $$dir clean; \
	done

# Aliases (удобные псевдонимы)
# Чтобы писать "make lab01" вместо "make lab01-expression-evaluation"
lab01: lab01-expression-evaluation
lab02: lab02-conditional-branching
lab03: lab03-array-fixed-points
lab04: lab04-bitwise-pair-swap
lab05: lab05-byte-progression-check
