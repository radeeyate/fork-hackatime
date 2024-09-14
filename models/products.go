package models

// ProductLabelReverseResolver returns all projects for a given label
type ProductLabelReverseResolver func(l string) []string

type Product struct {
	ID          uint   `json:"id" gorm:"primary_key"`
	Name        string `json:"name"`
	Price       int    `json:"price"`
	Description string `json:"description"`
	Image       string `json:"image"`
}

func (p *Product) IsValid() bool {
	return p.Name != "" && p.Price > 0 && p.Description != ""
}
