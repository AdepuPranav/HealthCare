from PyQt5.QtWidgets import (
    QPushButton, 
    QLabel, 
    QLineEdit, 
    QGraphicsDropShadowEffect
)
from PyQt5.QtCore import QPropertyAnimation, QEasingCurve
from PyQt5.QtGui import QColor

class StyledButton(QPushButton):
    def __init__(self, text, parent=None):
        super().__init__(text, parent)
        self.setStyleSheet("""
            QPushButton {
                background-color: #3498db;
                color: white;
                border: none;
                border-radius: 10px;
                padding: 8px 15px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #2980b9;
            }
        """)

class StyledLabel(QLabel):
    def __init__(self, text, parent=None):
        super().__init__(text, parent)
        self.setStyleSheet("""
            QLabel {
                color: #2c3e50;
                font-size: 16px;
                font-weight: normal;
                padding: 5px;
            }
        """)

class ValidatedInput(QLineEdit):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setStyleSheet("""
            QLineEdit {
                border: 2px solid #bdc3c7;
                border-radius: 10px;
                padding: 8px;
                font-size: 14px;
            }
            QLineEdit:focus {
                border-color: #3498db;
            }
        """)
        self.textChanged.connect(self.validate_input)

    def validate_input(self):
        text = self.text()
        if not text:
            self.setStyleSheet("""
                QLineEdit {
                    border: 2px solid #bdc3c7;
                    border-radius: 10px;
                    padding: 8px;
                }
            """)
        elif text.strip():
            self.setStyleSheet("""
                QLineEdit {
                    border: 2px solid #2ecc71;
                    border-radius: 10px;
                    padding: 8px;
                }
            """)
        else:
            self.setStyleSheet("""
                QLineEdit {
                    border: 2px solid #e74c3c;
                    border-radius: 10px;
                    padding: 8px;
                }
            """)

def apply_animation(widget):
    animation = QPropertyAnimation(widget, b"geometry")
    animation.setDuration(500)
    animation.setStartValue(widget.geometry())
    animation.setEndValue(widget.geometry().adjusted(0, 0, 10, 10))
    animation.setEasingCurve(QEasingCurve.OutBounce)
    animation.start()