const Tesseract = require('tesseract.js');
const fs = require('fs');

exports.extractTextFromImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'Aucun fichier uploadé' });
        }

        const filePath = req.file.path;

        console.log(`Début de l'analyse OCR pour ${filePath}...`);

        const { data: { text } } = await Tesseract.recognize(
            filePath,
            'fra', // Langue française
            { logger: m => console.log(m) }
        );

        // Supprimer le fichier temporaire après analyse
        fs.unlinkSync(filePath);

        // Analyse basique du texte pour extraire SPH, CYL, AXE (Exemple simple)
        const extractedData = {
            raw_text: text,
            sphere: text.match(/SPH[^\d]*([+-]?\d+\.?\d*)/i)?.[1] || null, // Cherche "SPH : -2.00"
            cylindre: text.match(/CYL[^\d]*([+-]?\d+\.?\d*)/i)?.[1] || null, // Cherche "CYL : -0.50"
            axe: text.match(/AXE[^\d]*(\d+)/i)?.[1] || null // Cherche "AXE : 180"
        };

        res.json(extractedData);
    } catch (error) {
        console.error('Erreur OCR:', error);
        res.status(500).json({ message: 'Erreur lors de l\'analyse de l\'ordonnance', error: error.message });
    }
};
