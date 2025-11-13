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
    # In the DB the table `personal` uses the column `id_persona` both as
    # primary key and as FK to `persona(id_persona)`. Model this by making
    # the OneToOneField the primary key and mapping it to db_column 'id_persona'.
    persona = models.OneToOneField(
        'pkmn_fbdd.Persona',
        on_delete=models.CASCADE,
        primary_key=True,
        db_column='id_persona',
        related_name='personal'
    )
    esparticipante = models.BooleanField(default=False, blank=True)
    esorganizador = models.BooleanField(default=False, blank=True)
    class Meta:
        db_table = 'personal'
    def __str__(self):
        # `self.persona` es la relación; `self.pk` será el id_persona
        return str(self.pk) + " - " + str(self.persona)