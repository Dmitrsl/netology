# coding: utf-8

CATEGORIES = ['Электроника', 'Дети', 'Авто']

def word_count(text):
	"""
	Возвращает количество слов в тексте.

	Пример
	word_count('Посчитай количество слов в тексте')

	Результат
	5
	"""

	return len(text.split(' '))
