﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	ДанныеРегистра = РегистрыСведений.УчетнаяПолитика.ПолучитьПоследнее(МоментВремени());
	МетодСписания = ДанныеРегистра.МетодСписания;
	Если НЕ ЗначениеЗаполнено(МетодСписания) Тогда
		
		Отказ = Истина;
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не задана учетная политика!";
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли;
	
	ОбработкаПроведенияОУ(МетодСписания, Отказ, Режим);

	Движения.Управленческий.Записывать = Истина;
	Движения.Управленческий.Записать();
	
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
		|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма
		|ПОМЕСТИТЬ ВТ_ДанныеДок
		|ИЗ
		|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|	И РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры = &ВидыНоменклатурыТовар
		|
		|СГРУППИРОВАТЬ ПО
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	УправленческийОстатки.Субконто3 КАК Субконто3
		|ПОМЕСТИТЬ ВТ_ПартииПоСкладу
		|ИЗ
		|	РегистрБухгалтерии.Управленческий.Остатки(
		|			,
		|			Счет = &Счет,
		|			&СкладНоменклатураПартия,
		|			Субконто1 = &Склад
		|				И Субконто2 В
		|					(ВЫБРАТЬ
		|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура
		|					ИЗ
		|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК УправленческийОстатки
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
		|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление,
		|	ВТ_ДанныеДок.Количество КАК Количество,
		|	ВТ_ДанныеДок.Сумма КАК Сумма,
		|	УправленческийОстатки.Субконто2 КАК Партия,
		|	ЕСТЬNULL(УправленческийОстатки.КоличествоОстаток, 0) КАК КоличествоПартии,
		|	ЕСТЬNULL(УправленческийОстатки.СуммаОстаток, 0) КАК СуммаПартии
		|ИЗ
		|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Управленческий.Остатки(
		|				&МоментВремени,
		|				Счет = &Счет,
		|				&НоменклатураПартия,
		|				Субконто1 В
		|						(ВЫБРАТЬ
		|							ВТ_ДанныеДок.Номенклатура КАК Номенклатура
		|						ИЗ
		|							ВТ_ДанныеДок КАК ВТ_ДанныеДок)
		|					И Субконто2 В
		|						(ВЫБРАТЬ
		|							ВТ_ПартииПоСкладу.Субконто3 КАК Субконто3
		|						ИЗ
		|							ВТ_ПартииПоСкладу КАК ВТ_ПартииПоСкладу)) КАК УправленческийОстатки
		|		ПО ВТ_ДанныеДок.Номенклатура = УправленческийОстатки.Субконто1
		|
		|УПОРЯДОЧИТЬ ПО
		|	ВЫРАЗИТЬ(УправленческийОстатки.Субконто2 КАК Документ.ПриходнаяНакладная).МоментВремени УБЫВ
		|ИТОГИ
		|	МАКСИМУМ(Количество),
		|	МАКСИМУМ(Сумма),
		|	СУММА(КоличествоПартии)
		|ПО
		|	Номенклатура";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Счет", ПланыСчетов.Управленческий.Товары);
	Запрос.УстановитьПараметр("ВидыНоменклатурыТовар", Перечисления.ВидыНоменклатуры.Товар);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Склад", Склад);
	
	СкладНоменклатураПартия = Новый Массив;
	СкладНоменклатураПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Склад);
	СкладНоменклатураПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	СкладНоменклатураПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Партия);
	Запрос.УстановитьПараметр("СкладНоменклатураПартия", СкладНоменклатураПартия);
	
	НоменклатураПартия = Новый Массив;
	НоменклатураПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	НоменклатураПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Партия);
	Запрос.УстановитьПараметр("НоменклатураПартия", НоменклатураПартия);
	
	Если МетодСписания = Перечисления.УчетнаяПолитика.ФИФО Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, ".МоментВремени УБЫВ", ".МоментВремени ВОЗР");
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		НеХватает = ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КОличествоПартии;
		
		Если НеХватает > 0 Тогда
		
			Отказ = Истина;
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтрШаблон("Не хватает товара %1 в количестве %2", ВыборкаНоменклатура.НоменклатураПредставление, НеХватает);
			Сообщение.Сообщить();
		
		КонецЕсли;
		
		Если Отказ Тогда
		
			Продолжить;
		
		КонецЕсли;
		
		ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
		
		ВсегоСписать = ВыборкаНоменклатура.Количество;
		Пока ВсегоСписать > 0 И ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			СписатьПоПартии = МИН(ВсегоСписать, ВыборкаДетальныеЗаписи.КоличествоПартии);
			ВсегоСписать = ВсегоСписать - СписатьПоПартии;
			
			Себестоимость = СписатьПоПартии / ВыборкаДетальныеЗаписи.КоличествоПартии * ВыборкаДетальныеЗаписи.СуммаПартии;
			
			Движение = Движения.Управленческий.Добавить();
			Движение.СчетДт = ПланыСчетов.Управленческий.ПрибылиУбытки;
			Движение.СчетКт = ПланыСчетов.Управленческий.Товары;
			Движение.Период = Дата;
			Движение.КоличествоКт = СписатьПоПартии;
			Движение.Сумма = Себестоимость;
			Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Склад] = Склад;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Партия] = ВыборкаДетальныеЗаписи.Партия;
			
			
		КонецЦикла;
		
		Движение = Движения.Управленческий.Добавить();
		Движение.СчетДт = ПланыСчетов.Управленческий.Покупатели;
		Движение.СчетКт = ПланыСчетов.Управленческий.ПрибылиУбытки;
		Движение.Период = Дата;
		Движение.Сумма = ВыборкаНоменклатура.Сумма;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаНоменклатура.Номенклатура;
		
	КонецЦикла;
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры

Процедура ОбработкаПроведенияОУ(МетодСписания, Отказ, Режим)
	
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	Движения.Продажи.Записывать = Истина;
	
	Движения.ОстаткиНоменклатуры.Записать();
	
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
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры КАК НоменклатураВидНоменклатуры,
		|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
		|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма
		|ПОМЕСТИТЬ ВТ_ДанныеДок
		|ИЗ
		|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура,
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
		|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление,
		|	ВТ_ДанныеДок.НоменклатураВидНоменклатуры КАК ВидНоменклатуры,
		|	ВТ_ДанныеДок.Количество КАК Количество,
		|	ВТ_ДанныеДок.Сумма КАК Сумма,
		|	ОстаткиНоменклатурыОстатки.Партия КАК Партия,
		|	ЕСТЬNULL(ОстаткиНоменклатурыОстатки.КоличествоОстаток, 0) КАК КоличествоПартии,
		|	ЕСТЬNULL(ОстаткиНоменклатурыОстатки.СебестоимостьОстаток, 0) КАК СуммаПартии
		|ИЗ
		|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ОстаткиНоменклатуры.Остатки(
		|				&МоментВремени,
		|				Номенклатура В
		|					(ВЫБРАТЬ
		|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура
		|					ИЗ
		|						ВТ_ДанныеДок КАК ВТ_ДанныеДок
		|					ГДЕ
		|						ВТ_ДанныеДок.НоменклатураВидНоменклатуры = &ВидНоменклатурыТовар)) КАК ОстаткиНоменклатурыОстатки
		|		ПО ВТ_ДанныеДок.Номенклатура = ОстаткиНоменклатурыОстатки.Номенклатура
		|
		|УПОРЯДОЧИТЬ ПО
		|	ОстаткиНоменклатурыОстатки.Партия.МоментВремени УБЫВ
		|ИТОГИ
		|	МАКСИМУМ(ВидНоменклатуры),
		|	МАКСИМУМ(Количество),
		|	МАКСИМУМ(Сумма),
		|	СУММА(КоличествоПартии)
		|ПО
		|	Номенклатура";
	
	Запрос.УстановитьПараметр("ВидНоменклатурыТовар", Перечисления.ВидыНоменклатуры.Товар);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Если МетодСписания = Перечисления.УчетнаяПолитика.ФИФО Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, ".МоментВремени УБЫВ", ".МоментВремени ВОЗР");
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		Если ВыборкаНоменклатура.ВидНоменклатуры = Перечисления.ВидыНоменклатуры.Услуга Тогда
			
			Если НЕ Отказ ТОгда
				
				Движение = Движения.Продажи.Добавить();
				Движение.Период = Дата;
				Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
				Движение.Количество = ВыборкаНоменклатура.Количество;
				Движение.Себестоимость = 0;
				Движение.СуммаПродажи = ВыборкаНоменклатура.Сумма;
				
			КонецЕсли;
			
			Продолжить;
			
		КонецЕсли;
		
		НеХватает = ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КОличествоПартии;
		Если НеХватает > 0 Тогда
			
			Отказ = Истина;
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтрШаблон("Не хватает товара %1 в количестве %2", ВыборкаНоменклатура.НоменклатураПредставление, НеХватает);
			Сообщение.Сообщить();
			
		КонецЕсли;
		
		Если Отказ Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		
		ИтогоСписать = ВыборкаНоменклатура.Количество;
		
		Выборка = ВыборкаНоменклатура.Выбрать();
		
		ИтогоСебестоимость = 0;
		
		Пока ИтогоСписать > 0 И Выборка.Следующий() Цикл
			
			СписатьПоПартии = МИН(ИтогоСписать, Выборка.КоличествоПартии);
			ИтогоСписать = ИтогоСписать - СписатьПоПартии;
			
			СебестоимостьСписать = СписатьПоПартии / выборка.КоличествоПартии * Выборка.СуммаПартии;
			
			Движение = Движения.ОстаткиНоменклатуры.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Движение.Партия = Выборка.Партия;
			Движение.Количество = СписатьПоПартии;
			Движение.Себестоимость = СебестоимостьСписать;
			
			ИтогоСебестоимость = ИтогоСебестоимость + Движение.Себестоимость; 
			
		КонецЦикла;
		
		Движение = Движения.Продажи.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
		Движение.Количество = ВыборкаНоменклатура.Количество;
		Движение.Себестоимость = ИтогоСебестоимость;
		Движение.СуммаПродажи = ВыборкаНоменклатура.Сумма;
				
	КонецЦикла;

	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры
