from django.db import models

class Persona(models.Model):
    id_persona = models.AutoField(primary_key=True)
    fecha_de_nacimiento = models.DateField()
    apellido_paterno = models.CharField(max_length=100)
    apellido_materno = models.CharField(max_length=100)
    nombres = models.CharField(max_length=200)
    espersonal = models.BooleanField()
    esespectador = models.BooleanField()
    class Meta:
        db_table = 'persona' 

    def __str__(self):
        return str(self.id_persona) + " - " + self.nombres