// Package windows provides OS-level abstractions.
package windows

// PrinterInfo holds information about a printer.
type PrinterInfo struct {
	Name      string `json:"name"`
	IsDefault bool   `json:"is_default"`
	Status    string `json:"status"`
}

// ListPrinters returns a list of installed printers.
func ListPrinters() ([]PrinterInfo, error) {
	// Stub for now. On Windows, this would use WMI or wmic.
	return []PrinterInfo{
		{Name: "Microsoft Print to PDF", IsDefault: true, Status: "Ready"},
		{Name: "OneNote (Desktop)", IsDefault: false, Status: "Ready"},
		{Name: "Fax", IsDefault: false, Status: "Ready"},
	}, nil
}
