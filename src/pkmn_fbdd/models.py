from django.db import models

class Persona(models.Model):
    id_persona = models.AutoField(primary_key=True)
    fecha_de_nacimiento = models.DateField()
    apellido_paterno = models.CharField(max_length=100)
    apellido_materno = models.CharField(max_length=100)
    nombres = models.CharField(max_length=200)
    espersonal = models.BooleanField(default=False, blank=True)
    esespectador = models.BooleanField(default=False, blank=True)
    class Meta:
        db_table = 'persona' 

    def __str__(self):
        return str(self.id_persona) + " - " + self.nombres
    
class Personal(models.Model):
    id_persona = models.AutoField(primary_key=True)
    # Link to Persona: map the field to the existing DB column name.
    # If your DB column is 'persona' (not 'id_persona'), set db_column='persona' so Django uses the correct column.
    persona = models.OneToOneField('pkmn_fbdd.Persona', on_delete=models.CASCADE, db_column='persona', related_name='personal')
    esparticipante = models.BooleanField(default=False, blank=True)
    esorganizador = models.BooleanField(default=False, blank=True)
    class Meta:
        db_table = 'personal'
    def __str__(self):
        return str(self.id_persona) + " - " + str(self.persona)