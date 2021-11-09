﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.НоменклатураВЭксплуатации.Записывать = Истина;
	Движения.СебестоимостьНоменклатуры.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
		|	СУММА(ПриходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
		|	СУММА(ПриходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма,
		|	ПриходнаяНакладнаяСписокНоменклатуры.СрокГодности КАК СрокГодности
		|ИЗ
		|	Документ.ПриходнаяНакладная.СписокНоменклатуры КАК ПриходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	ПриходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура,
		|	ПриходнаяНакладнаяСписокНоменклатуры.СрокГодности
		|ИТОГИ
		|	СУММА(Количество),
		|	СУММА(Сумма)
		|ПО
		|	Номенклатура";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		Движение = Движения.СебестоимостьНоменклатуры.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
		Движение.Количество = ВыборкаНоменклатура.Количество;
		Движение.Сумма = ВыборкаНоменклатура.Сумма;
		
		ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
		
		ЧислоСекундВСутках = 86400;
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			Движение = Движения.НоменклатураВЭксплуатации.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.СрокГодности = Дата + ВыборкаДетальныеЗаписи.СрокГодности * ЧислоСекундВСутках;
			Движение.Количество = ВыборкаДетальныеЗаписи.Количество;
			
		КонецЦикла;
		
	КонецЦикла;

	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры
