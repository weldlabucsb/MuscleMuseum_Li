from arc import *
from scipy.constants import physical_constants
from scipy.constants import Rydberg as C_Rydberg
from scipy.constants import m_e as C_m_e
from scipy.constants import c as C_c
from math import log

def getTransitionFrequencyLithium7(self, n1, l1, j1, n2, l2, j2, s=0.5, s2=None):
    if s2 is None:
        s2 = s
    if n1 == 2 and l1 == 0 and j1 == float(1/2) and n2 == 2 and l2 == 1 and j2 == float(1/2):
        freq = 446800129853000.0
    elif n1 == 2 and l1 == 1 and j1 == float(1/2) and n2 == 2 and l2 == 0 and j2 == float(1/2):
        freq = -446800129853000.0
    elif n1 == 2 and l1 == 0 and j1 == float(1/2) and n2 == 2 and l2 == 1 and j2 == float(3/2):
        freq = 446810183289000.0
    elif n1 == 2 and l1 == 1 and j1 == float(3/2) and n2 == 2 and l2 == 0 and j2 == float(1/2):
        freq = -446810183289000.0
    else:
        freq = (self.getEnergy(n2, l2, j2, s=s2) - self.getEnergy(n1, l1, j1, s=s)) * C_e / C_h
    return freq
def getLandegjExactEdit(self, l, j, s=0.5):
    if j == 0:
        return float(0)
    else:
        return self.gL * (j * (j + 1.0) - s * (s + 1.0) + l * (l + 1.0)) / (
            2.0 * j * (j + 1.0)
        ) + self.gS * (j * (j + 1.0) + s * (s + 1.0) - l * (l + 1.0)) / (
            2.0 * j * (j + 1.0)
        )
        
def getLandegfExactEdit(self, l, j, f, s=0.5):
    if f == 0:
        return float(0)
    else:
        gf = self.getLandegjExact(l, j, s) * (
            f * (f + 1) - self.I * (self.I + 1) + j * (j + 1.0)
        ) / (2 * f * (f + 1.0)) + self.gI * (
            f * (f + 1.0) + self.I * (self.I + 1.0) - j * (j + 1.0)
        ) / (
            2.0 * f * (f + 1.0)
        )
        return gf
AlkaliAtom.getLandegjExact = getLandegjExactEdit
AlkaliAtom.getLandegfExact = getLandegfExactEdit

class Lithium7(AlkaliAtom):  # Li
    """
    Properties of lithium 7 atoms
    """

    # ALL PARAMETERES ARE IN ATOMIC UNITS (HATREE)
    # model potential parameters from Marinescu et.al, PRA 49:982 (1994)
    alphaC = 0.1923
    """
        model potential parameters from [#c1]_

    """
    a1 = [2.47718079, 3.45414648, 2.51909839, 2.51909839]
    """
        model potential parameters from [#c1]_

    """
    a2 = [1.84150932, 2.55151080, 2.43712450, 2.43712450]
    """
        model potential parameters from [#c1]_

    """
    a3 = [-0.02169712, -0.21646561, 0.32505524, 0.32505524]
    """
        model potential parameters from [#c1]_

    """
    a4 = [-0.11988362, -0.06990078, 0.10602430, 0.10602430]
    """
        model potential parameters from [#c1]_

    """
    rc = [0.61340824, 0.61566441, 2.34126273, 2.34126273]
    """
        model potential parameters from [#c1]_

    """

    Z = 3

    I = 1.5  # 3/2

    NISTdataLevels = 42
    ionisationEnergy = 5.391719  #: (eV) NIST Ref. [#c11]_.
    gI = -0.0011822130;
    quantumDefect = [
        [
            [0.3995101, 0.0290, 0.0, 0.0, 0.0, 0.0],
            [0.0471780, -0.024, 0.0, 0.0, 0.0, 0.0],
            [0.002129, -0.01491, 0.1759, -0.8507, 0.0, 0.0],
            [-0.000077, 0.021856, -0.4211, 2.3891, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        ],
        [
            [0.3995101, 0.0290, 0.0, 0.0, 0.0, 0.0],
            [0.0471665, -0.024, 0.0, 0.0, 0.0, 0.0],
            [0.002129, -0.01491, 0.1759, -0.8507, 0.0, 0.0],
            [-0.000077, 0.021856, -0.4211, 2.3891, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        ],
    ]
    """
        quantum defects for :math:`nS` and :math:`nP` states are
        from Ref. [#c6]_. Quantum defects for :math:`D_j` and :math:`F_j`
        states are from [#c7]_.

    """

    levelDataFromNIST = "li_NIST_level_data.ascii"
    dipoleMatrixElementFile = "li7_dipole_matrix_elements.npy"
    quadrupoleMatrixElementFile = "li7_quadrupole_matrix_elements.npy"

    minQuantumDefectN = 4

    precalculatedDB = "li7_precalculated.db"
    literatureDMEfilename = 'lithium7_literature_dme.csv'
    # levels that are for smaller n than ground level,
    # but are above in energy due to angular part
    extraLevels = []

    groundStateN = 2

    #: source NIST, Atomic Weights and Isotopic Compositions [#c14]_
    mass = 7.0160034366 * physical_constants["atomic mass constant"][0]
    #: source NIST, Atomic Weights and Isotopic Compositions [#c14]_
    abundance = 0.9241

    gL = 1 - physical_constants["electron mass"][0] / mass

    scaledRydbergConstant = (
        (mass - C_m_e)
        / (mass)
        * C_Rydberg
        * physical_constants["inverse meter-electron volt relationship"][0]
    )

    elementName = "Li7"
    meltingPoint = 180.54 + 273.15  #: in K

    #: source of HFS magnetic dipole and quadrupole constants
    hyperfineStructureData = "li7_hfs_data.csv"

    def getPressure(self, temperature):
        """
        Pressure of atomic vapour at given temperature (in K).

        Uses equation and values from [#c3]_. Values from table 3.
        (accuracy +-1 %) are used for both liquid and solid phase of Li.

        """

        if temperature < self.meltingPoint:
            # Li is in solid phase (from table 3. of the cited reference
            # "precisely fitted equations / +- 1%)
            return (
                10.0
                ** (
                    2.881
                    + 7.790
                    - 8423.0 / temperature
                    - 0.7074 * log(temperature) / log(10.0)
                )
                * 133.322368
            )

        elif temperature < 1000.0 + 273.15:
            # Li is in liquid phase (from table 3. of the cited reference
            # "precisely fitted equations / +- 1%)
            return (
                10.0
                ** (
                    2.881
                    + 8.409
                    - 8320.0 / temperature
                    - 1.0255 * log(temperature) / log(10.0)
                )
                * 133.322368
            )
        else:
            print(
                "ERROR: Li vapour pressure above 1000 C is unknown \
                    (limits of experimental interpolation)"
            )
            return 0
Lithium7.getTransitionFrequency = getTransitionFrequencyLithium7        