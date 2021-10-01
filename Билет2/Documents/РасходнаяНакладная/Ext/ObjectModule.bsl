﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.ПартииНоменклатуры.Записывать = Истина;
	Движения.ПартииНоменклатуры.Записать();
	
	Движения.Управленческий.Записывать = Истина;
	Движения.Управленческий.Записать();
	
	Движения.Продажи.Записывать = Истина;
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ПартииНоменклатуры");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Партия", "Партия");
	Блокировка.Заблокировать();
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Дата КАК Период,
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК СуммаПродажи,
	|	РасходнаяНакладнаяСписокНоменклатуры.Партия КАК Партия
	|ПОМЕСТИТЬ ВТ_ДанныеДок
	|ИЗ
	|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
	|ГДЕ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Дата,
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура,
	|	РасходнаяНакладнаяСписокНоменклатуры.Партия
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура,
	|	Партия
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|	ВТ_ДанныеДок.Количество КАК Количество,
	|	ВЫБОР
	|		КОГДА ВТ_ДанныеДок.Номенклатура.ВидНоменклатуры = &ВидНоменклатуры
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ЭтоТовар,
	|	ЕСТЬNULL(ПартииНоменклатурыОстатки.КоличествоОстаток, 0) КАК КоличествоПартии,
	|	ЕСТЬNULL(ПартииНоменклатурыОстатки.СуммаОстаток, 0) КАК СуммаПартии,
	|	ВТ_ДанныеДок.СуммаПродажи КАК СуммаПродажи,
	|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление,
	|	ВТ_ДанныеДок.Партия.Представление КАК ПартияПредставление,
	|	ВТ_ДанныеДок.Партия КАК Партия
	|ИЗ
	|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПартииНоменклатуры.Остатки(
	|				&МоментВремени,
	|				(Номенклатура, Партия) В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|						ВТ_ДанныеДок.Партия КАК Партия
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК ПартииНоменклатурыОстатки
	|		ПО ВТ_ДанныеДок.Номенклатура = ПартииНоменклатурыОстатки.Номенклатура
	|			И ВТ_ДанныеДок.Партия = ПартииНоменклатурыОстатки.Партия";
	
	Запрос.УстановитьПараметр("ВидНоменклатуры", Перечисления.ВидыНоменклатуры.Товар);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Если Выборка.ЭтоТовар Тогда
			
			НеХватает = Выборка.Количество - Выборка.КоличествоПартии;
			Если НеХватает > 0 Тогда
				
				Отказ = Истина;
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = СтрШаблон("Не хватает товара: %1 по партии: %2 в количестве: %3", Выборка.НоменклатураПредставление, Выборка.ПартияПредставление, НеХватает);
				Сообщение.Сообщить();
				
			КонецЕсли;
			
			Если Отказ Тогда
				Продолжить;
			КонецЕсли;
			
			Себестоимость = ?(Выборка.Количество = Выборка.КоличествоПартии, 
			Выборка.СуммаПартии, 
			Выборка.Количество * Выборка.СуммаПартии / Выборка.КоличествоПартии);
			
			Движение = Движения.ПартииНоменклатуры.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Движение.Партия = Выборка.Партия;
			Движение.Количество = Выборка.Количество;
			Движение.Сумма = Себестоимость;
			
			Движение = Движения.Продажи.Добавить();
			Движение.Период = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Движение.Количество = Выборка.Количество;
			Движение.Себестоимость = Себестоимость;
			Движение.СуммаПродажи = Выборка.СуммаПродажи;
		ИНаче
			
			Движение = Движения.Продажи.Добавить();
			Движение.Период = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Движение.Количество = Выборка.Количество;
			Движение.Себестоимость = 0;
			Движение.СуммаПродажи = Выборка.СуммаПродажи;
			
		КонецЕсли;
	
	КонецЦикла;
	
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрБухгалтерии.Управленческий");
	ЭлементБлокировки.УстановитьЗначение("Счет", ПланыСчетов.Управленческий.Товары);
	ЭлементБлокировки.УстановитьЗначение(ПланыВидовХарактеристик.ВидыСубконто.Склад, Склад);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура, "Номенклатура");
	Блокировка.Заблокировать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Склад КАК Склад,
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Проект КАК Проект,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма
	|ПОМЕСТИТЬ ВТ_ДанныеДок
	|ИЗ
	|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
	|ГДЕ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
	|	И РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры = &ВидНоменклатуры
	|
	|СГРУППИРОВАТЬ ПО
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура,
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Склад,
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка.Проект
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура,
	|	Склад
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление,
	|	ВТ_ДанныеДок.Склад.Представление КАК СкладПредставление,
	|	ВТ_ДанныеДок.Количество КАК Количество,
	|	ЕСТЬNULL(УправленческийОстатки.КоличествоОстаток, 0) КАК ОстатокНаСкладе,
	|	ЕСТЬNULL(УправленческийСебестоимость.СуммаОстаток, 0) КАК СуммаСебестоимость,
	|	ЕСТЬNULL(УправленческийСебестоимость.КоличествоОстаток, 0) КАК КоличествоСебестоимость,
	|	ВТ_ДанныеДок.Склад КАК Склад,
	|	ВТ_ДанныеДок.Проект КАК Проект,
	|	ВТ_ДанныеДок.Сумма КАК Сумма
	|ИЗ
	|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Управленческий.Остатки(
	|				&МоментВремени,
	|				Счет = &Счет,
	|				&МасСубконто,
	|				(Субконто1, Субконто2) В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|						ВТ_ДанныеДок.Склад КАК Склад
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК УправленческийОстатки
	|		ПО ВТ_ДанныеДок.Номенклатура = УправленческийОстатки.Субконто1
	|			И ВТ_ДанныеДок.Склад = УправленческийОстатки.Субконто2
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Управленческий.Остатки(
	|				&МоментВремени,
	|				Счет = &Счет,
	|				&МасСубконтоСебестоимость,
	|				Субконто1 В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК УправленческийСебестоимость
	|		ПО ВТ_ДанныеДок.Номенклатура = УправленческийСебестоимость.Субконто1";
	МасСубконто = Новый Массив;
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	МасСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Склад);
	Запрос.УстановитьПараметр("МасСубконто", МасСубконто);
	
	МасСубконтоСебестоимость = Новый Массив;
	МасСубконтоСебестоимость.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	Запрос.УстановитьПараметр("МасСубконтоСебестоимость", МасСубконтоСебестоимость);
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("ВидНоменклатуры", Перечисления.ВидыНоменклатуры.Товар);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Счет", ПланыСчетов.Управленческий.Товары);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		НеХватает = Выборка.Количество - Выборка.ОстатокНаСкладе;
		Если НеХватает > 0 Тогда
		
			Отказ = Истина;
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтрШаблон("Не хвататет товара: %1 по складу %2 в количестве %3", Выборка.НоменклатураПредставление, Выборка.СкладПредставление, НеХватает);
			Сообщение.Сообщить();
			
		КонецЕсли;
		
		Если Отказ Тогда
		
			Продолжить;
		
		КонецЕсли;
		
		Себестоимость = ?(Выборка.Количество = Выборка.КоличествоСебестоимость, 
			Выборка.СуммаСебестоимость, 
			Выборка.Количество  * Выборка.СуммаСебестоимость / Выборка.КоличествоСебестоимость);
		
		Движение = Движения.Управленческий.Добавить();
		Движение.СчетДт = ПланыСчетов.Управленческий.ПрибылиУбытки;
		Движение.СчетКт = ПланыСчетов.Управленческий.Товары;
		Движение.Период = Дата;
		Движение.Сумма = Себестоимость;
		Движение.КоличествоКт = Выборка.Количество;
		//Движение.КоличествоДт = Выборка.Количество;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Проект] = Выборка.Проект;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = Выборка.Номенклатура;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Склад] = Выборка.Склад;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = Выборка.Номенклатура;
		
		Движение = Движения.Управленческий.Добавить();
		Движение.СчетДт = ПланыСчетов.Управленческий.Покупатели;
		Движение.СчетКт = ПланыСчетов.Управленческий.ПрибылиУбытки;
		Движение.Период = Дата;
		Движение.Сумма = Выборка.Сумма;
		//Движение.КоличествоКт = Выборка.Количество;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Проект] = Выборка.Проект;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = Выборка.Номенклатура;
		
	КонецЦикла;
	
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
	
КонецПроцедуры
