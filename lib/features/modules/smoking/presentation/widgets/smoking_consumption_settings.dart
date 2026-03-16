import 'package:flutter/material.dart';

class SmokingConsumptionSettings extends StatelessWidget {
  final bool isDark;
  final TextEditingController priceController;
  final TextEditingController packsController;
  final String selectedCurrency;
  final DateTime selectedDate;
  final Function(String?) onCurrencyChanged;
  final Function(String) onPriceChanged;
  final VoidCallback onDateTap;

  const SmokingConsumptionSettings({
    super.key,
    required this.isDark,
    required this.priceController,
    required this.packsController,
    required this.selectedCurrency,
    required this.selectedDate,
    required this.onCurrencyChanged,
    required this.onPriceChanged,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Últimas informações de consumo:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'Preencha os dados do seu consumo de cigarro no momento (ou de antes da tentativa atual de parada), salve, e ative o módulo.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Preço do maço:"),
                  SizedBox(
                    width: 160,
                    height: 40,
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 4, right: 4),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCurrency,
                              isDense: true,
                              icon: const Icon(Icons.arrow_drop_down,
                                  size: 16),
                              alignment: Alignment.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color:
                                    isDark ? Colors.white : Colors.black87,
                              ),
                              selectedItemBuilder: (BuildContext context) {
                                return ['R\$', 'US\$', 'EUR', 'ARS\$']
                                    .map<Widget>((String item) {
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              onChanged: onCurrencyChanged,
                              items: ['R\$', 'US\$', 'EUR', 'ARS\$']
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                String currencyName = '';
                                switch (value) {
                                  case 'R\$':
                                    currencyName = 'Real';
                                    break;
                                  case 'US\$':
                                    currencyName = 'Dólar Americano';
                                    break;
                                  case 'EUR':
                                    currencyName = 'Euro';
                                    break;
                                  case 'ARS\$':
                                    currencyName = 'Peso Argentino';
                                    break;
                                }
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text('$value - $currencyName'),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                            minWidth: 50, maxWidth: 80),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.indigo, width: 2),
                        ),
                      ),
                      onChanged: onPriceChanged,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Maços por dia:"),
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: TextField(
                      controller: packsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: '0',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Colors.indigo, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Data de parada:"),
                  InkWell(
                    onTap: onDateTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
