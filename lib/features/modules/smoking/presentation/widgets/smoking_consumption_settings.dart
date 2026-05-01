import 'package:flutter/material.dart';

class SmokingConsumptionSettings extends StatefulWidget {
  final bool isDark;
  final bool isModuleActive;
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
    this.isModuleActive = false,
    required this.priceController,
    required this.packsController,
    required this.selectedCurrency,
    required this.selectedDate,
    required this.onCurrencyChanged,
    required this.onPriceChanged,
    required this.onDateTap,
  });

  @override
  State<SmokingConsumptionSettings> createState() => _SmokingConsumptionSettingsState();
}

class _SmokingConsumptionSettingsState extends State<SmokingConsumptionSettings> {
  @override
  void initState() {
    super.initState();
    // Adicionar listeners para atualizar o estado quando o texto mudar
    widget.priceController.addListener(_onTextChanged);
    widget.packsController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.priceController.removeListener(_onTextChanged);
    widget.packsController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

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
          style: TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withAlpha(0x0D)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark ? Colors.white10 : Colors.grey[300]!,
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
                      controller: widget.priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      enabled: !widget.isModuleActive,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: widget.isModuleActive
                            ? Colors.grey.shade600
                            : (widget.priceController.text.isNotEmpty && widget.priceController.text != '0,00'
                                ? (widget.isDark ? Colors.white : Colors.black)
                                : (widget.isDark ? Colors.white38 : Colors.black38)),
                      ),
                      decoration: InputDecoration(
                        filled: widget.isModuleActive,
                        fillColor: widget.isModuleActive ? Colors.grey.shade100 : null,
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 4, right: 4),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: widget.selectedCurrency,
                              isDense: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 16),
                              alignment: Alignment.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: widget.isDark ? Colors.white : Colors.black87,
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
                                        color: widget.isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              onChanged: widget.onCurrencyChanged,
                              items: ['R\$', 'US\$', 'EUR', 'ARS\$']
                                  .map<DropdownMenuItem<String>>((String value) {
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
                        prefixIconConstraints: const BoxConstraints(minWidth: 50, maxWidth: 80),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        hintText: '0,00',
                        hintStyle: TextStyle(
                          color: widget.isDark ? Colors.white38 : Colors.black38,
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                      onTap: () {
                        // Limpa o campo se ainda tiver o valor padrão
                        if (widget.priceController.text == '0,00') {
                          widget.priceController.clear();
                        }
                      },
                      onChanged: widget.onPriceChanged,
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
                      controller: widget.packsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      enabled: !widget.isModuleActive,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: widget.isModuleActive
                            ? Colors.grey.shade600
                            : (widget.packsController.text.isNotEmpty && widget.packsController.text != '0'
                                ? (widget.isDark ? Colors.white : Colors.black)
                                : (widget.isDark ? Colors.white38 : Colors.black38)),
                      ),
                      decoration: InputDecoration(
                        filled: widget.isModuleActive,
                        fillColor: widget.isModuleActive ? Colors.grey.shade100 : null,
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: widget.isDark ? Colors.white38 : Colors.black38,
                          fontWeight: FontWeight.normal,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                      onTap: () {
                        // Limpa o campo se ainda tiver o valor padrão
                        if (widget.packsController.text == '0') {
                          widget.packsController.clear();
                        }
                      },
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
                    onTap: widget.onDateTap,
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
                        "${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}",
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
