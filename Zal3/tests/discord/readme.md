Zestaw testów do zadania crc.
Autor: Kamil Szymczak

Niniejsze testy służą do testowania rozwiązań do zadania crc.

Nie ma żadnej gwarancji, że program przechodzący wszystkie
testy jest porawny. Celem tego zestawu testów jest pomoc
w tworzeniu rozwiązania, mierzenie czasu wykonania oraz
wyłapywanie potencjalnych prostych błędów. Zalecany jest
zdrowy rozsądek oraz uwaga.

Paczka sprawdza:
    - Poprawność na testach przygotowanych przez autorów,
    - Poprawność kodu wyjścia przy niepoprawnych parametrach
      przekazanych jako argumenty programu oraz przy niepoprawnych
      plikach z dziurami.
    - Poprawność obliczania kodu CRC na przygotowanym zestawie testów.

Aby rozpocząć sprawdzanie, należy umieścić plik crc.asm w niniejszym
katalogu.

Aby uruchomić testy przygotowane przez autorów, należy użyć komendy

./run_sample_tests.sh

Uwaga plik2 był zbyt duży, aby załączyć go z tą paczką. Jeśli
ktoś chciałby testować wraz tym plikiem należy skopiować go do
podkatalogu tests i pozostawić nazwę plik2. Można to zrobić komendą

cp ścieżka/do/pliku2 tests/plik2

Aby uruchomić testy sprawdzające poprawność kodu wyjścia przy
niepoprawnych parametrach lub niepoprawnych plikach, należy użyć
komendy

./run_exit_code_tests.sh


Aby uruchomić przygotowany zestaw testów, należy użyć komendy

python3 gen.py

Ta komenda wygeneruje testy. Następnie uruchamiamy sprawdzanie komendą

./run_large_tests.sh
