#NoEnv
#Warn
#SingleInstance, force
#NoTrayIcon
SetBatchLines -1
ScanStatus := False
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Add, GroupBox, x8 y8 w578 h175 cBlue vGroupA, Folder or Drive
Gui, Add, Picture, x20 y30 w64 h64 vTopIcon Icon50, shell32
Gui, Add, Picture, x20 y30 w64 h64 vDefaultIcon Icon4, shell32

Gui, Add, Button, x372 y25 w200 h32 vDefaultFolder gDefaultFolder, Default folder icon in Windows

Gui, Add, Text, x17 y151, &Path
Gui, Add, Edit, x137 y146 w315 h23 +Disabled vFolder
Gui, Add, Button, x459 y146 w53 h23 vBtnAhkFile gSelectFolder, &Browse

Gui, Add, GroupBox, x8 y185 w578 h175 cBlue vGroupB, &New Icon

Gui, Add, Picture, x20 y207 w64 h64 vBottomIcon Icon50, shell32
Gui, Add, Text, x17 y325, Custom &Icon (.ico file)
Gui, Add, Edit, x137 y322 w315 h23 +Disabled vIcoFile
Gui, Add, Button, x459 y322 w53 h23 vBtnIcoFile gSelectIcon, Browse
Gui, Add, Button, x8 y365 w578 h32 vReplaceIcon gReplaceIcon, Replace Icon

Gui, Show, w594 h400, Faldi Pro

GuiControl, Disable, DefaultFolder
GuiControl, Disable, ReplaceIcon
GuiControl, Hide, DefaultIcon
Return

;!----------------------------------------------:  FUNCTION [Drag And Drop Files]

GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
    for i, file in FileArray
        SplitPath, file, name, dir, ext, name_no_ext, drive ;-: Info о файле

    FileGetAttrib, MyAttributes, %file%
    If InStr(MyAttributes,"D") { ; ---------------------------: Если выбранная папка это папка
        vFolder := file "\" ; --------------------------------: Имя папки в переменую [C:\Program Files\]
        GuiControl,, Folder, %vFolder% ; ---------------------: Имя папки в Edit

        DesktopIni := vFolder "Desktop.ini" ; ----------------:                  [C:\Program Files\Desktop.ini]
        DesktopIniProcessing(vFolder, DesktopIni) ; ----------: Обработка файла  [Desktop.ini]
        EnableButton() ; -------------------------------------: Активация Button [Replace Icon]
    }

    if (ext == "ico") { ; ------------------------------------: Если у файла расширение [ico]
        GuiControl,, IcoFile, %file% ; -----------------------: Запись файла в Edit     [IcoFile]
        GuiControl,, BottomIcon, %file% ;---------------------: Предпросмотр иконки
        EnableButton() ; -------------------------------------: Активация Button        [Replace Icon]
    }
}

;!----------------------------------------------: FUNCTION [EnableButton()]

EnableButton(){
    GuiControlGet, Folder,, Folder ; ---------: Folder  = Edit [Folder]
    GuiControlGet, IcoFile,, IcoFile ; -------: IcoFile = Edit [IcoFile]

    if (Folder != "" && IcoFile != "") { ; ---: Если Edit [Folder] и Edit [IcoFile] не пустые
        GuiControl, Enable, ReplaceIcon ; -----: Активировать Button       [Replace Icon]
    }
}

;!----------------------------------------------: BUTTON [DefaultFolder]

DefaultFolder(){
    DelZ404() ; ----------------------------: Delete [.z404]
    DelDesktopIni() ; ----------------------: Delete [Desktop.ini]
    GuiControl, Disable, DefaultFolder ; ---: Деактивация Button [Default Folder...]
    GuiControl, Show, DefaultIcon ;---------: Показать иконку [DefaultIcon]
}

;!----------------------------------------------:  FUNCTION [DelDesktopIni()]

DelDesktopIni(){
    GuiControlGet, Folder,, Folder

    FileIni := Folder "\Desktop.ini"

    If FileExist(FileIni){ ;--------------------------------------: Если файл    [Desktop.ini] существует
        FileSetAttrib, -RSH, %Folder% ;---------------------------: Снетие атрибутов
        FileDelete, %FileIni% ;-----------------------------------: удалить файл [Desktop.ini]
    }

}

;!----------------------------------------------:  FUNCTION [DelZ404()]

DelZ404(){
    GuiControlGet, Folder,, Folder

    FolderIcon := Folder "\.z404"

    If( InStr( FileExist(FolderIcon), "D") ){ ;---: Если папка    [.z404] существует
        FileSetAttrib, -RSH, %FolderIcon% ;-------: Снетие атрибутов
        FileRemoveDir, %FolderIcon%, 1 ;----------: удалить папку [.z404]
    }
}

;!----------------------------------------------:  FUNCTION [HideDefaultIcon()] Скрыть иконку папки по улолчанию

HideDefaultIcon(){
    GuiControlGet, Folder,, Folder ;---: Получить начение из Edit [vFolder]
    GuiControl, hide, DefaultIcon ;----: Скрыть Picture [DefaultIcon]
}

;!----------------------------------------------: FUNCTION [DesktopIniProcessing()]

DesktopIniProcessing(folder, file){
    if FileExist(file){ ;----------------------------------------: Если файл               [Desktop.ini] существует
        HideDefaultIcon() ;--------------------------------------: Скрыть Picture          [DefaultIcon]

        FileRead, DesktopText, %file% ;--------------------------: Читаем содержимое файла [Desktop.ini]

        TmpFile = %A_Temp%\tmp-0-z404.tmp
        if FileExist(TmpFile) ;----------------------------------: Если    [tmp] файл существует
            FileDelete, %TmpFile% ;------------------------------: Удалить [tmp] файл

        FileAppend, %DesktopText%, %TmpFile%, UTF-16 ;-----------: Запись из [Desktop.ini] в [tmp] файл

        Category := ".ShellClassInfo"
        IniRead, IconPath, %TmpFile%, %Category%, IconResource ;-: Получение значения из [tmp] файла

        Loop, Parse, IconPath, `,
        {
            if(A_Index == 1)
                VarIcon = %A_LoopField% ;-------------------------: Запись в [VarIcon] путь и имя файла
            if(A_Index == 2)
                VarIndexIcon = %A_LoopField%
        }

        PathIcon := SubStr(VarIcon, 2, 2) ;-----------------------: Из [VarIcon] получаем 2 и 3 знак
        if (PathIcon != ":\") ;-----------------------------------: Если в [VarIcon] нет [:\]
            PathIcon := folder VarIcon ;--------------------------: Добавить [vFolder + VarIcon]
        Else
            PathIcon := VarIcon ;---------------------------------: Если есть [:\] к [PathIcon = VarIcon]

        GuiControl,, TopIcon, %PathIcon% ;------------------------: Запись в Picture [TopIcon]

        EnableButton() ; -----------------------------------------: Активация Button [Replace Icon]
        GuiControl,Enable, DefaultFolder ; -----------------------: Активация Button [Default Folder...]
    } else {
        GuiControl, Show, DefaultIcon ;---------------------------: Показать иконку [DefaultIcon]
        GuiControl, Disable, DefaultFolder ; ---------------------: Деактивация Button [Default Folder...]
    }
}

;!----------------------------------------------: FUNCTION [ReplaceIcon()]

ReplaceIcon(){
    GuiControlGet, Folder,, Folder ;------------------------------: Folder = Получить начение из Edit [vFolder]
    Folder := % RegExReplace(Folder, "\\?$", "") ;----------------: Удаление последнего слеша из пути

    ;-------------------------------------------------------------: Создать Desktop.ini в папке [.z404]
    GuiControlGet, IcoFile,, IcoFile ;----------------------------: IcoFile = Получить начение из Edit [vIcoFile]
    Text := "[.ShellClassInfo]`nIconResource=.z404\ico.ico,0" ;---: Текст файла 
    FileTmp := A_Temp "tmp-1-z404.tmp" ;----------------------------: Путь и имя [временного файла]
    FileAppend, %Text%, %FileTmp% ;-------------------------------: Записать текст в [временный файл]
    FileSetAttrib, +AH, %FileTmp% ;-------------------------------: Добавить атрибуты [временному файлу]
    FileCopy, %FileTmp%, %Folder%\Desktop.ini ;-------------------: Копировать в нужную нам папку [временный файл]
    FileSetAttrib, +R, %Folder% ;---------------------------------: Добавить атрибут для папки
    Sleep, 100
    FileDelete, %FileTmp% ;---------------------------------------: Удалить [временный файл]

    ;--------------------------------------------: Создание временной папки [x.z404]
    FolderIcon := "x.z404"
    DelZ404() ;----------------------------------: Если существует - удалить папку [.z404]
    FileCreateDir, %FolderIcon% ;----------------: Создать папку [x.z404]
    FileCopy, %IcoFile%, %FolderIcon%\ico.ico ;--: Копировать иконку в папку [x.z404]
    Sleep, 100

    ;-------------------------------: Создать файл Desktop.ini внутри папки [.z404]
    Text := "[.ShellClassInfo]`nIconResource=%SystemRoot%\System32\SHELL32.dll,49" ;---: Текст файла 
    FileDesktop := FolderIcon "\Desktop.ini" ;-----------------------------------------: Путь и имя файла [Desktop.ini]
    FileAppend, %Text%, %FileDesktop% ;------------------------------------------------: Записать текст в [Desktop.ini]
    FileSetAttrib, +AH, %FileDesktop% ;------------------------------------------------: Добавить атрибуты файлу [Desktop.ini]
    Sleep, 100

    ;---------------------------------------------: Создание папки [.z404]
    NewFolder := Folder "\.z404"
    FileCopyDir, %FolderIcon%, %NewFolder%, 1 ;---: Копируем папку [x.z404] в [.z404]
    FileSetAttrib, +AHR, %NewFolder% ;------------: Добавить атрибуты папке [.z404]
    FileRemoveDir, %FolderIcon%, 1 ;--------------: Удалить папку [x.z404]

    GuiControl,, TopIcon, %IcoFile% ;--------------: Запись в Picture [*.ico]
    HideDefaultIcon() ;----------------------------: Скрыть Picture   [DefaultIcon]
    GuiControl,Enable, DefaultFolder ; ------------: Активация Button [Default Folder...]
    Return
}

;!----------------------------------------------: FUNCTION [SelectIcon()]

SelectIcon(){
    FileSelectFile, SelectedFile, 3, , Open a file, Icon File (*.ico) ;-: Выбрать [*.ico] файл
    if SelectedFile = ;-------------------------------------------------: Если ничего не выбрано
        MsgBox,,, You didn't choose anything [о_о]..., 1 ;--------------: MsgBox  [Ты ничего не выбрал]
    else {
        GuiControl,, IcoFile, %SelectedFile% ;--------------------------: Edit                [IcoFile]    = SelectedFile
        GuiControl,, BottomIcon, %SelectedFile% ;-----------------------: Picture             [BottomIcon] = SelectedFile
        EnableButton() ; -----------------------------------------------: Активировать Button [Replace Icon]
    }
}

;!----------------------------------------------: FUNCTION [SelectFolder()]

SelectFolder(){
    FileSelectFolder, vFolder, ::{20d04fe0-3aea-1069-a2d8-08002b30309d} ;-: Запись выбранного пути в [vFolder]
        if vFolder = ;----------------------------------------------------: Если ничего не выбрано
            MsgBox,,, You didn't choose anything [о_о]..., 1 ;------------: MsgBox  [Ты ничего не выбрал]
        else { ;----------------------------------------------------------: Если выбрано
            GuiControl,, Folder, %vFolder% ;------------------------------: Запись в Edit [vFolder] выбранный путь
            DesktopIni := vFolder "Desktop.ini" ; ------------------------: DesktopIni =  [C:\Program Files\Desktop.ini]
            DesktopIniProcessing(vFolder, DesktopIni) ; ------------------: Обработка файла  [Desktop.ini]
            EnableButton() ; ---------------------------------------------: Активировать Button [Replace Icon]
        }
    }

    GuiEscape:
    GuiClose:
    ButtonCancel:
    ExitApp