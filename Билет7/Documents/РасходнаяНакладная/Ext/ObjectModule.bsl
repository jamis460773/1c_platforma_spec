﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	МетодСписания = РегистрыСведений.УчетнаяПолитика.ПолучитьПоследнее(Дата).МетодСписания;
	Если НЕ ЗначениеЗаполнено(МетодСписания) Тогда
		
		Отказ = Истина;
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не задана учётная политика!";
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли;	
	
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ОстаткиНоменклатуры");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
	Блокировка.Заблокировать();
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма
	|ПОМЕСТИТЬ ВТ_ДанныеДок
	|ИЗ
	|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
	|ГДЕ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|	ВТ_ДанныеДок.Номенклатура.ВидНоменклатуры КАК ВидНоменклатуры,
	|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление,
	|	ВТ_ДанныеДок.Количество КАК Количество,
	|	ВТ_ДанныеДок.Сумма КАК СуммаПродажиРуб,
	|	ЕСТЬNULL(ОстаткиНоменклатурыОстатки.КоличествоОстаток, 0) КАК КоличествоПартии,
	|	ЕСТЬNULL(ОстаткиНоменклатурыОстатки.СуммаРубОстаток, 0) КАК СебестоимостьПартии,
	|	ОстаткиНоменклатурыОстатки.Партия КАК Партия
	|ИЗ
	|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ОстаткиНоменклатуры.Остатки(
	|				&МоментВремени,
	|				Номенклатура В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК ОстаткиНоменклатурыОстатки
	|		ПО ВТ_ДанныеДок.Номенклатура = ОстаткиНоменклатурыОстатки.Номенклатура
	|
	|УПОРЯДОЧИТЬ ПО
	|	ОстаткиНоменклатурыОстатки.Партия.МоментВремени УБЫВ
	|ИТОГИ
	|	МАКСИМУМ(ВидНоменклатуры),
	|	МАКСИМУМ(Количество),
	|	МАКСИМУМ(СуммаПродажиРуб),
	|	СУММА(КоличествоПартии),
	|	СУММА(СебестоимостьПартии)
	|ПО
	|	Номенклатура";
	
	Если МетодСписания = Перечисления.УчетнаяПолитика.ФИФО Тогда
		ЗАпрос.Текст = СтрЗаменить(Запрос.Текст, "МоментВремени УБЫВ", "МоментВремени");
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ВидНоменклатурыТовар", Перечисления.ВидыНоменклатуры.Товар);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		Если ВыборкаНоменклатура.ВидНоменклатуры = Перечисления.ВидыНоменклатуры.Товар Тогда
			
			НеХватает = ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КоличествоПартии;
			Если НеХватает > 0 Тогда
				
				Отказ = Истина;
				
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = СтрШаблон("Не хватает товара %1 в количестве %2", ВыборкаНоменклатура.НоменклатураПредставление, НеХватает);
				Сообщение.Сообщить();		
				
			КонецЕсли;
			
			Если Отказ Тогда
				Продолжить;
			КонецЕсли;
			
			СебестоимостьПартий = 0;
			КоличествоСписать = ВыборкаНоменклатура.Количество;
			
			Выборка = ВыборкаНоменклатура.Выбрать();
			Пока КоличествоСписать > 0 И Выборка.Следующий() Цикл
				
				КоличествоПартии = МИН(КоличествоСписать, Выборка.КоличествоПартии);
				
				СебестоимостьПартии = ?(КоличествоПартии = Выборка.КоличествоПартии, 
				Выборка.СебестоимостьПартии, 
				КоличествоПартии * Выборка.СебестоимостьПартии / Выборка.КоличествоПартии);
				
				КоличествоСписать = КоличествоСписать - КоличествоПартии;
				
				Движение = Движения.ОстаткиНоменклатуры.Добавить();
				Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
				Движение.Период = Дата;
				Движение.Номенклатура = Выборка.Номенклатура;
				Движение.Партия = Выборка.Партия;
				Движение.Количество = КоличествоПартии;
				Движение.СуммаРуб = СебестоимостьПартии;
				
				СебестоимостьПартий  = СебестоимостьПартий + Движение.СуммаРуб;
				
			КонецЦикла;
			
		Иначе
			
			СебестоимостьПартий = 0;
			
			Если Отказ Тогда
				Продолжить;
			КонецЕсли;
			
		КонецЕсли;
		
		Движение = Движения.Продажи.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
		Движение.Количество = ВыборкаНоменклатура.Количество;
		Движение.СебестоимостьРуб = СебестоимостьПартий;
		Движение.СебестоимостьUSD = СебестоимостьПартий / КурсUSD;
		Движение.СуммаПродажиРуб = ВыборкаНоменклатура.СуммаПродажиРуб;
		Движение.СуммаПродажиUSD = ВыборкаНоменклатура.СуммаПродажиРуб / КурсUSD;
		
		
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	// регистр ОстаткиНоменклатуры Расход
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	Для Каждого ТекСтрокаСписокНоменклатуры Из СписокНоменклатуры Цикл
	КонецЦикла;

	// регистр Продажи 
	Движения.Продажи.Записывать = Истина;
	Для Каждого ТекСтрокаСписокНоменклатуры Из СписокНоменклатуры Цикл
	КонецЦикла;

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры
